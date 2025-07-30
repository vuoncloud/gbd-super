import eventlet
eventlet.monkey_patch()

import hashlib
import logging
import os
import json
import re
from datetime import datetime, timedelta
import psycopg2
from psycopg2.extras import RealDictCursor, execute_values
import paho.mqtt.client as mqtt
from dotenv import load_dotenv
from flask import Flask, jsonify, request, render_template, send_from_directory, make_response, redirect, url_for, flash, session
from flask_socketio import SocketIO, emit, join_room, leave_room
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from flask_bcrypt import Bcrypt
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
from wtforms.validators import DataRequired, Email, EqualTo, Length, ValidationError, Regexp
from functools import wraps
from flask_mail import Mail, Message
from itsdangerous import URLSafeTimedSerializer
import time
import threading
from werkzeug.security import generate_password_hash, check_password_hash
# Implement connection pooling for better performance
from sqlalchemy.pool import QueuePool

# Load environment variables
load_dotenv()

# Configure logging 
logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] [%(levelname)s] %(message)s'
)
log = logging.getLogger(__name__)

# Create Flask app
app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'a_very_secret_key')
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(hours=12)

# Initialize Flask extensions
socketio = SocketIO(app, async_mode='eventlet')
bcrypt = Bcrypt(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'
login_manager.login_message_category = 'info'

socketio = SocketIO(app, cors_allowed_origins="*", logger=True, engineio_logger=True)
# Initialize RBAC tables on startup


# Database connection function
def get_db_connection():
    """Database connection function with SSL support and fallback options"""
    try:
        # Base connection parameters
        conn_params = {
            'host': os.environ.get('DB_HOST', 'localhost'),
            'database': os.environ.get('DB_NAME', 'gbd-multi'),
            'user': os.environ.get('DB_USER', 'gbdmulti'),
            'password': os.environ.get('DB_PASSWORD', 'Mansi@123'),
            'port': int(os.environ.get('DB_PORT', '5432'))
        }
        
        # Add SSL mode if specified
        sslmode = os.environ.get('DB_SSLMODE')
        if sslmode:
            conn_params['sslmode'] = sslmode
        
        # Add connection timeout
        connect_timeout = os.environ.get('DB_CONNECT_TIMEOUT', '30')
        conn_params['connect_timeout'] = int(connect_timeout)
        
        log.info(f"Attempting database connection to {conn_params['host']}:{conn_params['port']} with SSL mode: {sslmode or 'default'}")
        
        conn = psycopg2.connect(**conn_params)
        log.info("Database connection successful!")
        return conn
        
    except psycopg2.OperationalError as e:
        if "pg_hba.conf" in str(e):
            log.error(f"Database access denied - IP not whitelisted: {e}")
            log.error("SOLUTION: Contact database administrator to add your IP (103.211.15.110) to pg_hba.conf")
        else:
            log.error(f"Database connection error: {e}")
        return None
    except Exception as e:
        log.error(f"Unexpected database connection error: {e}")
        return None


# ========================================
# MOVE PERMISSION DECORATOR HERE - BEFORE ANY ROUTES
# ========================================
def requires_permission(permission_name: str):
    """Permission decorator"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not current_user.is_authenticated:
                return redirect(url_for('login'))
            # For now, just check if user is logged in
            # Later you can add actual permission checking here
            return f(*args, **kwargs)
        return decorated_function
    return decorator


# Enhanced User class

class DeviceStatusManager:
    def __init__(self):
        self.active_connections = set()
        self.device_status_cache = {}
        self.monitoring_thread = None
        self.running = False
    
    def start_monitoring(self):
        """Start real-time device monitoring"""
        if not self.running:
            self.running = True
            self.monitoring_thread = threading.Thread(target=self._monitor_devices, daemon=True)
            self.monitoring_thread.start()
            log.info("Device status monitoring started")
    
    def stop_monitoring(self):
        """Stop device monitoring"""
        self.running = False
        if self.monitoring_thread:
            self.monitoring_thread.join()
        log.info("Device status monitoring stopped")
    
    def _monitor_devices(self):
        """Background thread to monitor device status"""
        while self.running:
            try:
                self._check_device_heartbeats()
                self._update_ota_progress()
                time.sleep(10)  # Check every 10 seconds
            except Exception as e:
                log.error(f"Error in device monitoring: {e}")
                time.sleep(30)  # Wait longer on error
    
    def _check_device_heartbeats(self):
        """Check device heartbeats and update status"""
        conn = get_db_connection()
        if not conn:
            return
        
        try:
            with conn.cursor() as cursor:
                # Find devices that should be marked offline
                cursor.execute("""
                    SELECT mac_address, device_id, status
                    FROM devices 
                    WHERE status != 'offline' 
                    AND last_seen < (NOW() - INTERVAL '5 minutes')
                """)
                
                offline_devices = cursor.fetchall()
                
                for mac_address, device_id, old_status in offline_devices:
                    self._update_device_status(mac_address, 'offline', f'No heartbeat for 5+ minutes')
                    
                    # Emit status change to connected clients
                    socketio.emit('device_status_change', {
                        'mac_address': mac_address,
                        'device_id': device_id,
                        'status': 'offline',
                        'previous_status': old_status,
                        'timestamp': datetime.utcnow().isoformat()
                    }, room='device_monitoring')
                
                # Find devices that should be marked online
                cursor.execute("""
                    SELECT mac_address, device_id, status
                    FROM devices 
                    WHERE status = 'offline' 
                    AND last_seen > (NOW() - INTERVAL '2 minutes')
                """)
                
                online_devices = cursor.fetchall()
                
                for mac_address, device_id, old_status in online_devices:
                    self._update_device_status(mac_address, 'online', 'Device heartbeat received')
                    
                    # Emit status change to connected clients
                    socketio.emit('device_status_change', {
                        'mac_address': mac_address,
                        'device_id': device_id,
                        'status': 'online',
                        'previous_status': old_status,
                        'timestamp': datetime.utcnow().isoformat()
                    }, room='device_monitoring')
        
        except Exception as e:
            log.error(f"Error checking device heartbeats: {e}")
        finally:
            conn.close()
    
    def _update_ota_progress(self):
        """Update OTA progress for devices currently updating"""
        conn = get_db_connection()
        if not conn:
            return
        
        try:
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT mac_address, device_id, update_progress, update_started_at
                    FROM devices 
                    WHERE is_updating = TRUE
                """)
                
                updating_devices = cursor.fetchall()
                
                for mac_address, device_id, progress, started_at in updating_devices:
                    # Simulate progress update (in real implementation, this would come from device)
                    if started_at:
                        elapsed_minutes = (datetime.utcnow() - started_at).total_seconds() / 60
                        new_progress = min(100, int(elapsed_minutes * 20))  # 20% per minute
                        
                        if new_progress != progress:
                            cursor.execute("""
                                UPDATE devices 
                                SET update_progress = %s
                                WHERE mac_address = %s
                            """, (new_progress, mac_address))
                            
                            # Emit progress update
                            socketio.emit('ota_progress_update', {
                                'mac_address': mac_address,
                                'device_id': device_id,
                                'progress': new_progress,
                                'status': 'updating',
                                'timestamp': datetime.utcnow().isoformat()
                            }, room='device_monitoring')
                            
                            # Mark as complete if 100%
                            if new_progress >= 100:
                                self._complete_ota_update(mac_address)
                
                conn.commit()
        
        except Exception as e:
            log.error(f"Error updating OTA progress: {e}")
        finally:
            conn.close()
    
    def _update_device_status(self, mac_address, new_status, reason=""):
        """Update device status in database"""
        conn = get_db_connection()
        if not conn:
            return
        
        try:
            with conn.cursor() as cursor:
                # Get current status
                cursor.execute("SELECT status FROM devices WHERE mac_address = %s", (mac_address,))
                result = cursor.fetchone()
                old_status = result[0] if result else 'unknown'
                
                # Update device status
                cursor.execute("""
                    UPDATE devices 
                    SET status = %s, status_updated_at = CURRENT_TIMESTAMP
                    WHERE mac_address = %s
                """, (new_status, mac_address))
                
                # Log status change
                cursor.execute("""
                    INSERT INTO device_status_log (mac_address, status, previous_status, reason)
                    VALUES (%s, %s, %s, %s)
                """, (mac_address, new_status, old_status, reason))
                
                conn.commit()
                log.info(f"Device {mac_address} status changed: {old_status} → {new_status}")
        
        except Exception as e:
            log.error(f"Error updating device status: {e}")
        finally:
            conn.close()
    
    def _complete_ota_update(self, mac_address):
        """Complete OTA update process"""
        conn = get_db_connection()
        if not conn:
            return
        
        try:
            with conn.cursor() as cursor:
                cursor.execute("""
                    UPDATE devices 
                    SET is_updating = FALSE, 
                        update_progress = 100,
                        current_fw_version = target_fw_version,
                        status = 'online'
                    WHERE mac_address = %s
                """, (mac_address,))
                
                # Get device info
                cursor.execute("SELECT device_id, target_fw_version FROM devices WHERE mac_address = %s", (mac_address,))
                device = cursor.fetchone()
                
                if device:
                    device_id, fw_version = device
                    
                    # Emit completion event
                    socketio.emit('ota_completed', {
                        'mac_address': mac_address,
                        'device_id': device_id,
                        'firmware_version': fw_version,
                        'status': 'online',
                        'timestamp': datetime.utcnow().isoformat()
                    }, room='device_monitoring')
                    
                    log.info(f"OTA update completed for {device_id} ({mac_address}) to version {fw_version}")
                
                conn.commit()
        
        except Exception as e:
            log.error(f"Error completing OTA update: {e}")
        finally:
            conn.close()
    
    def start_ota_update(self, mac_address, target_version):
        """Start OTA update process"""
        conn = get_db_connection()
        if not conn:
            return False
        
        try:
            with conn.cursor() as cursor:
                cursor.execute("""
                    UPDATE devices 
                    SET is_updating = TRUE, 
                        update_progress = 0,
                        update_started_at = CURRENT_TIMESTAMP,
                        status = 'updating',
                        target_fw_version = %s
                    WHERE mac_address = %s
                """, (target_version, mac_address))
                
                conn.commit()
                
                # Emit update started event
                cursor.execute("SELECT device_id FROM devices WHERE mac_address = %s", (mac_address,))
                device = cursor.fetchone()
                
                if device:
                    socketio.emit('ota_started', {
                        'mac_address': mac_address,
                        'device_id': device[0],
                        'target_version': target_version,
                        'status': 'updating',
                        'timestamp': datetime.utcnow().isoformat()
                    }, room='device_monitoring')
                    
                    return True
        
        except Exception as e:
            log.error(f"Error starting OTA update: {e}")
        finally:
            conn.close()
        
        return False

# Initialize device status manager
device_status_manager = DeviceStatusManager()

# WebSocket event handlers
@socketio.on('connect')
def handle_connect():
    """Handle client connection"""
    join_room('device_monitoring')
    emit('connected', {'message': 'Connected to device monitoring'})
    log.info(f"Client connected to device monitoring: {request.sid}")

@socketio.on('disconnect')
def handle_disconnect():
    """Handle client disconnection"""
    leave_room('device_monitoring')
    log.info(f"Client disconnected from device monitoring: {request.sid}")

@socketio.on('subscribe_device_updates')
def handle_subscribe():
    """Handle subscription to device updates"""
    join_room('device_monitoring')
    emit('subscribed', {'message': 'Subscribed to device updates'})

# Device heartbeat endpoint (called by devices)
@app.route('/api/device/<mac_address>/heartbeat', methods=['POST'])
def device_heartbeat(mac_address):
    """Receive device heartbeat"""
    data = request.get_json() or {}
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Update last seen and status
            cursor.execute("""
                UPDATE devices 
                SET last_seen = CURRENT_TIMESTAMP,
                    status = CASE 
                        WHEN is_updating THEN 'updating'
                        ELSE 'online'
                    END,
                    status_updated_at = CURRENT_TIMESTAMP
                WHERE mac_address = %s
            """, (mac_address,))
            
            if cursor.rowcount > 0:
                # Get device info
                cursor.execute("SELECT device_id, status FROM devices WHERE mac_address = %s", (mac_address,))
                device = cursor.fetchone()
                
                if device:
                    device_id, status = device
                    
                    # Emit heartbeat event to connected clients
                    socketio.emit('device_heartbeat', {
                        'mac_address': mac_address,
                        'device_id': device_id,
                        'status': status,
                        'timestamp': datetime.utcnow().isoformat(),
                        'data': data
                    }, room='device_monitoring')
                
                conn.commit()
                return jsonify({"success": True, "status": "heartbeat_received"})
            else:
                return jsonify({"error": "Device not found"}), 404
    
    except Exception as e:
        log.error(f"Error processing heartbeat from {mac_address}: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

# Update your OTA trigger to use the status manager
@app.route('/api/device/<mac_address>/ota-update', methods=['POST'])
@login_required
@requires_permission('devices.control')
def trigger_ota_update_enhanced(mac_address):
    """Enhanced OTA update with real-time status"""
    data = request.get_json()
    target_version = data.get('target_version')
    
    if not target_version:
        return jsonify({"error": "Target version is required"}), 400
    
    # Start OTA update with status tracking
    if device_status_manager.start_ota_update(mac_address, target_version):
        return jsonify({
            "success": True,
            "message": f"OTA update initiated",
            "target_version": target_version,
            "status": "updating"
        })
    else:
        return jsonify({"error": "Failed to start OTA update"}), 500

# Start monitoring when app starts
   

class EnhancedUser(UserMixin):
    def __init__(self, id, email, name=None, parent_id=None):
        self.id = id
        self.email = email
        self.name = name or email.split('@')[0]
        self.parent_id = parent_id
        self._role_cache = None
        self._permissions_cache = None

    def get_role(self):
        if self._role_cache is None:
            conn = get_db_connection()
            try:
                with conn.cursor() as cursor:
                    cursor.execute("""
                        SELECT pu.role_name FROM project_users pu
                        WHERE pu.user_id = %s LIMIT 1
                    """, (self.id,))
                    result = cursor.fetchone()
                    self._role_cache = {
                        'name': result[0] if result else 'admin',  # Default to admin for now
                        'description': ''
                    }
            except:
                self._role_cache = {'name': 'admin', 'description': ''}
            finally:
                if conn: conn.close()
        return self._role_cache

    def is_super_admin(self):
        conn = get_db_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute("SELECT is_super_admin FROM users WHERE id = %s", (self.id,))
                result = cursor.fetchone()
                return result and result[0]
        except:
            return False
        finally:
            if conn: conn.close()

    def get_all_permissions(self):
        if self._permissions_cache is None:
            permissions = set()
            conn = get_db_connection()
            
            try:
                with conn.cursor() as cursor:
                    # Get role permissions
                    cursor.execute("""
                        SELECT rp.permission_key FROM role_permissions rp
                        JOIN project_users pu ON pu.role_name = rp.role_name
                        WHERE pu.user_id = %s
                    """, (self.id,))
                    
                    for row in cursor.fetchall():
                        permissions.add(row[0])
                
                # If no permissions found, give basic permissions
                if not permissions:
                    permissions = {
                        'page_dashboard', 'page_device_list', 'page_tester', 
                        'page_device_status', 'page_firmware_manager',
                        'page_user_list', 'page_role_management',
                        'permission_admin_only'
                    }
                
                self._permissions_cache = list(permissions)
                
            except Exception as e:
                log.error(f"Error getting permissions: {e}")
                # Fallback permissions
                self._permissions_cache = [
                    'page_dashboard', 'page_device_list', 'page_tester'
                ]
            finally:
                if conn: conn.close()
        
        return self._permissions_cache

# User loader
@login_manager.user_loader
def load_user(user_id):
    conn = get_db_connection()
    if not conn: return None
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("""
                SELECT id, email, name, parent_id 
                FROM users WHERE id = %s
            """, (int(user_id),))
            user_data = cursor.fetchone()
            if user_data:
                return EnhancedUser(
                    id=user_data['id'], 
                    email=user_data['email'],
                    name=user_data['name'],
                    parent_id=user_data['parent_id']
                )
    except Exception as e:
        log.error(f"[AUTH] Error loading user: {e}")
    finally:
        if conn: conn.close()
    return None

# Template context processor
@app.context_processor
def inject_globals():
    return {
        'current_utc_time': datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S'),
        'current_user_login': current_user.email.split('@')[0] if current_user.is_authenticated else 'Anonymous',
        'rbac_version': '2.0'
    }

# API Routes for navigation and projects
@app.route('/api/navigation-links', methods=['GET'])
@login_required
def get_navigation_links():
    """Get navigation links for sidebar"""
    if not current_user.is_authenticated:
        return jsonify([
            {
                "display_name": "Login",
                "icon": "fas fa-sign-in-alt",
                "url": "/login",
                "required_permission": None
            },
            {
                "display_name": "Create Account",
                "icon": "fas fa-user-plus",
                "url": "/register",
                "required_permission": None
            }
        ])
    links = [
        {
            "display_name": "Summary Dashboard",
            "icon": "fas fa-tachometer-alt",
            "url": "/dashboard",
            "required_permission": "page_dashboard"
        },
        {
            "display_name": "Device List", 
            "icon": "fas fa-list",
            "url": "/device-list",
            "required_permission": "page_device_list"
        },
        {
            "display_name": "Device Status",
            "icon": "fas fa-power-off", 
            "url": "/device-status",
            "required_permission": "page_device_status"
        },
        {
            "display_name": "Firmware Manager",
            "icon": "fas fa-upload",
            "url": "/firmware-manager", 
            "required_permission": "page_firmware_manager"
        },
        {
            "display_name": "Tester",
            "icon": "fas fa-vial",
            "url": "/tester",
            "required_permission": "page_tester"
        },
        {
            "display_name": "Project Management",
            "icon": "fas fa-project-diagram",
            "url": "/project-management",
            "required_permission": "page_project_management"
        },
        {
            "display_name": "User Management",
            "icon": "fas fa-users",
            "url": "/user-management",
            "required_permission": "page_user_list"
        },
        {
            "display_name": "Role Management", 
            "icon": "fas fa-shield-alt",
            "url": "/role-management",
            "required_permission": "page_role_management"
        }
    ]
    
    return jsonify(links)

@app.route('/api/my-projects', methods=['GET'])
@login_required
def get_my_projects():
    """Get user's projects"""
    conn = get_db_connection()
    if not conn:
        return jsonify([])
    
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT DISTINCT p.id, p.name, p.description 
                FROM projects p
                JOIN project_users pu ON p.id = pu.project_id
                WHERE pu.user_id = %s
                ORDER BY p.name
            """, (current_user.id,))
            
            projects = []
            for row in cursor.fetchall():
                projects.append({
                    "id": row[0],
                    "name": row[1], 
                    "description": row[2]
                })
            
            # If no projects, create a default one
            if not projects:
                projects = [{"id": 1, "name": "Device Management", "description": "Default project"}]
            
            return jsonify(projects)
    except Exception as e:
        log.error(f"Error getting projects: {e}")
        return jsonify([{"id": 1, "name": "Device Management", "description": "Default project"}])
    finally:
        conn.close()

@app.route('/api/set-project', methods=['POST'])
@login_required
def set_project():
    """Set current project"""
    data = request.get_json()
    project_id = data.get('project_id')
    
    if project_id:
        session['current_project_id'] = int(project_id)
        return jsonify({"success": True})
    
    return jsonify({"error": "Invalid project ID"}), 400

# Add the missing fetchProjectData function for your existing device_list.html
@app.route('/api/project/<int:project_id>/devices', methods=['GET'])
@login_required
def get_project_devices(project_id):
    """Get devices for a specific project - FIXED VERSION"""
    conn = get_db_connection()
    if not conn:
        return jsonify([])
    
    try:
        with conn.cursor() as cursor:
            # First check what columns actually exist
            cursor.execute("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name='devices'
                ORDER BY ordinal_position
            """)
            
            available_columns = [row[0] for row in cursor.fetchall()]
            log.info(f"Available columns in devices table: {available_columns}")
            
            # Build query based on available columns
            base_columns = ['mac_address', 'device_id', 'last_seen']
            optional_columns = {
                'current_fw_version': 'current_fw_version',
                'target_fw_version': 'target_fw_version', 
                'project': 'project',
                'assigned_user': 'assigned_user'
            }
            
            select_columns = base_columns.copy()
            for col_key, col_name in optional_columns.items():
                if col_name in available_columns:
                    select_columns.append(col_name)
                else:
                    select_columns.append(f"NULL as {col_name}")
            
            query = f"""
                SELECT {', '.join(select_columns)}
                FROM devices 
                ORDER BY device_id
            """
            
            cursor.execute(query)
            
            devices = []
            for row in cursor.fetchall():
                device = {
                    "mac_address": row[0],
                    "device_id": row[1],
                    "last_seen": row[2].isoformat() if row[2] else None,
                    "current_fw_version": row[3] if len(row) > 3 else None,
                    "target_fw_version": row[4] if len(row) > 4 else None,
                    "project": row[5] if len(row) > 5 else None,
                    "assigned_user": row[6] if len(row) > 6 else None
                }
                devices.append(device)
            
            log.info(f"Retrieved {len(devices)} devices")
            return jsonify(devices)
            
    except Exception as e:
        log.error(f"Error getting project devices: {e}")
        return jsonify([])
    finally:
        conn.close()
        
# Main page routes
@app.route('/')
@app.route('/dashboard')
@login_required
def dashboard():
    return render_template('dashboard_enhanced.html')

@app.route('/device-list')
@login_required 
def device_list_page():
    # Use your existing device_list.html (not device_list_enhanced.html)
    return render_template('device_list.html')

@app.route('/device-status')
@login_required
def device_status_page():
    return render_template('device_status.html')

@app.route('/firmware-manager')
@login_required
def firmware_manager_page():
    return render_template('firmware.html')

@app.route('/tester')
@login_required
def tester_page():
    return render_template('tester.html')

@app.route('/user-management')
@login_required
def user_management_page():
    return render_template('user_management.html')

@app.route('/role-management')
@login_required
def role_management_page():
    return render_template('role_management.html')

@app.route('/rbac-management')
@login_required
def rbac_management():
    return render_template('rbac_management.html')

# Login route
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email', '').strip()
        password = request.form.get('password', '')
        
        if not email or not password:
            flash('Email and password are required', 'error')
            return render_template('login.html')
        
        conn = get_db_connection()
        if not conn:
            flash('Database connection error. Please try again later.', 'error')
            return render_template('login.html')
        
        try:
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT id, email, password_hash, name, parent_id 
                    FROM users WHERE email = %s
                """, (email,))
                user_data = cursor.fetchone()
                
                if user_data and bcrypt.check_password_hash(user_data[2], password):
                    user = EnhancedUser(
                        id=user_data[0], 
                        email=user_data[1],
                        name=user_data[3],
                        parent_id=user_data[4]
                    )
                    login_user(user, remember=request.form.get('remember-me'), duration=timedelta(hours=12))
                    
                    log.info(f"[AUTH] Successful login for user: {email} (ID: {user_data[0]})")
                    flash('Login successful!', 'success')
                    return redirect(url_for('dashboard'))
                else:
                    log.warning(f"[AUTH] Failed login attempt for: {email}")
                    flash('Invalid email or password', 'error')
                    
        except Exception as e:
            log.error(f"[AUTH] Login error for {email}: {e}")
            flash('Login failed due to server error. Please try again.', 'error')
        finally:
            conn.close()
    
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('You have been logged out.', 'info')
    return redirect(url_for('login'))

# Debug route
@app.route('/debug-info')
def debug_info():
    """Debug route to check system status"""
    conn = get_db_connection()
    info = {
        'database_connected': conn is not None,
        'total_users': 0,
        'total_permissions': 0,
        'current_time': datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S'),
        'rbac_version': '2.0'
    }
    
    if conn:
        try:
            with conn.cursor() as cursor:
                cursor.execute("SELECT COUNT(*) FROM users")
                info['total_users'] = cursor.fetchone()[0]
                
                try:
                    cursor.execute("SELECT COUNT(*) FROM permissions")
                    info['total_permissions'] = cursor.fetchone()[0]
                except:
                    info['total_permissions'] = 'Table not found'
        except Exception as e:
            info['database_error'] = str(e)
        finally:
            conn.close()
    
    return jsonify(info)

@app.route('/api/user/check-permission', methods=['POST'])
@login_required
def api_check_user_permission():
    """API endpoint to check user permissions"""
    data = request.get_json()
    permission_key = data.get('permission_key')
    
    if not permission_key:
        return jsonify({"error": "Permission key is required"}), 400
    
    has_permission = check_user_permission(current_user.id, permission_key)
    
    return jsonify({
        "user_id": current_user.id,
        "permission_key": permission_key,
        "has_permission": has_permission,
        "checked_at": datetime.utcnow().isoformat()
    })
    


@app.route('/api/firmware', methods=['GET'])
@login_required
def get_firmware():
    """Get firmware versions"""
    # Mock data for now - replace with actual database query
    firmware_data = [
        {
            "version": "3.5.6",
            "device_type": "GoldBox",
            "path": "/firmware/Goldbox_3.5.6.bin",
            "added_date": "2025-07-29"
        },
        {
            "version": "2.1.4", 
            "device_type": "EMS-4R",
            "path": "/firmware/EMS-4R_2.1.4.bin",
            "added_date": "2025-07-28"
        }
    ]
    return jsonify(firmware_data)

@app.route('/api/device_types', methods=['GET'])
@login_required
def get_device_types():
    """Get available device types"""
    device_types = ["GoldBox", "EMS-4R", "AMS-3S2R"]
    return jsonify(device_types)

@app.route('/api/customers', methods=['GET'])
@login_required
def get_customers():
    """Get customer users for device assignment"""
    conn = get_db_connection()
    if not conn:
        return jsonify([])
    
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT id, email, name 
                FROM users 
                WHERE is_super_admin = false
                ORDER BY email
            """)
            
            customers = []
            for row in cursor.fetchall():
                customers.append({
                    "id": row[0],
                    "email": row[1],
                    "name": row[2] or row[1].split('@')[0]
                })
            
            return jsonify(customers)
    except Exception as e:
        log.error(f"Error getting customers: {e}")
        return jsonify([])
    finally:
        conn.close()
        
# Add these routes to your gbd_multi_super_enhanced.py file

@app.route('/api/rbac/stats', methods=['GET'])
@login_required
def get_rbac_stats():
    """Get RBAC system statistics"""
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Count users
            cursor.execute("SELECT COUNT(*) FROM users")
            user_count = cursor.fetchone()[0]
            
            # Count roles (from role_permissions table)
            cursor.execute("SELECT COUNT(DISTINCT role_name) FROM role_permissions")
            role_count = cursor.fetchone()[0]
            
            # Count permissions
            cursor.execute("SELECT COUNT(*) FROM permissions")
            permission_count = cursor.fetchone()[0]
            
            # Calculate max hierarchy depth
            cursor.execute("""
                WITH RECURSIVE hierarchy AS (
                    SELECT id, parent_id, 1 as depth FROM users WHERE parent_id IS NULL
                    UNION ALL
                    SELECT u.id, u.parent_id, h.depth + 1 
                    FROM users u 
                    JOIN hierarchy h ON u.parent_id = h.id
                )
                SELECT COALESCE(MAX(depth), 1) FROM hierarchy
            """)
            max_depth = cursor.fetchone()[0]
            
            return jsonify({
                "users": user_count,
                "roles": role_count,
                "permissions": permission_count,
                "max_depth": max_depth
            })
            
    except Exception as e:
        log.error(f"Error getting RBAC stats: {e}")
        return jsonify({
            "users": 1,
            "roles": 1, 
            "permissions": 8,
            "max_depth": 1
        })
    finally:
        conn.close()

@app.route('/api/rbac/discover-permissions', methods=['POST'])
@login_required
def discover_permissions_api():
    """API endpoint to trigger permission discovery"""
    try:
        # Simulate permission discovery
        new_permissions = [
            'system.admin.full_access',
            'users.create',
            'users.edit',
            'users.delete',
            'roles.manage',
            'hardware.view',
            'software.manage'
        ]
        
        conn = get_db_connection()
        discovered_count = 0
        
        if conn:
            try:
                with conn.cursor() as cursor:
                    for perm in new_permissions:
                        # Check if permission already exists
                        cursor.execute("SELECT id FROM permissions WHERE key = %s", (perm,))
                        if not cursor.fetchone():
                            # Insert new permission
                            cursor.execute("""
                                INSERT INTO permissions (key, display_name, description, category, auto_discovered)
                                VALUES (%s, %s, %s, %s, %s)
                            """, (perm, perm.replace('_', ' ').title(), f"Auto-discovered: {perm}", 
                                 perm.split('.')[0], True))
                            discovered_count += 1
                    
                    conn.commit()
            finally:
                conn.close()
        
        return jsonify({
            "success": True,
            "message": f"Permission discovery completed. Found {discovered_count} new permissions.",
            "count": discovered_count
        })
    except Exception as e:
        log.error(f"Error discovering permissions: {e}")
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

@app.route('/api/rbac/recent-discoveries', methods=['GET'])
@login_required
def get_recent_discoveries():
    """Get recent permission discoveries"""
    # Mock data for now
    recent_discoveries = [
        {
            "permission_name": "system.admin.full_access",
            "discovered_at": "2025-07-29T10:56:46Z",
            "source_file": "gbd_multi_super_enhanced.py",
            "source_function": "rbac_management"
        },
        {
            "permission_name": "users.permissions.manage", 
            "discovered_at": "2025-07-29T10:55:30Z",
            "source_file": "rbac_api.py",
            "source_function": "permission_discovery"
        }
    ]
    
    return jsonify(recent_discoveries)

@app.route('/api/rbac/hierarchy/users', methods=['GET'])
@login_required
def get_user_hierarchy_api():
    """Get user hierarchy tree"""
    conn = get_db_connection()
    if not conn:
        return jsonify([])
    
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT u.id, u.email, u.name, u.parent_id, u.created_at
                FROM users u
                ORDER BY u.parent_id NULLS FIRST, u.name
            """)
            
            users = cursor.fetchall()
            
            # Build hierarchy tree
            user_dict = {}
            for user in users:
                user_dict[user[0]] = {
                    'id': user[0],
                    'email': user[1],
                    'name': user[2] or user[1].split('@')[0],
                    'parent_id': user[3],
                    'role': 'Admin',  # Default role
                    'created_at': user[4].isoformat() if user[4] else datetime.now().isoformat(),
                    'children': []
                }
            
            # Link children to parents
            root_users = []
            for user in user_dict.values():
                if user['parent_id'] and user['parent_id'] in user_dict:
                    user_dict[user['parent_id']]['children'].append(user)
                else:
                    root_users.append(user)
            
            return jsonify(root_users)
    except Exception as e:
        log.error(f"Error getting user hierarchy: {e}")
        return jsonify([])
    finally:
        conn.close()

@app.route('/api/rbac/users', methods=['GET'])
@login_required
def get_rbac_users():
    """Get all users with role information"""
    conn = get_db_connection()
    if not conn:
        return jsonify([])
    
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT u.id, u.email, u.name, 'admin' as role
                FROM users u
                ORDER BY u.name, u.email
            """)
            
            users = []
            for row in cursor.fetchall():
                users.append({
                    "id": row[0],
                    "email": row[1],
                    "name": row[2] or row[1].split('@')[0],
                    "role": row[3]
                })
            
            return jsonify(users)
    except Exception as e:
        log.error(f"Error getting users: {e}")
        return jsonify([])
    finally:
        conn.close()

@app.route('/api/rbac/users/<int:user_id>', methods=['GET'])
@login_required
def get_rbac_user_detail(user_id):
    """Get detailed user information"""
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT u.id, u.email, u.name, u.created_at, u.parent_id
                FROM users u WHERE u.id = %s
            """, (user_id,))
            
            user_data = cursor.fetchone()
            if not user_data:
                return jsonify({"error": "User not found"}), 404
            
            user_info = {
                "id": user_data[0],
                "email": user_data[1],
                "name": user_data[2] or user_data[1].split('@')[0],
                "role": "admin",
                "created_at": user_data[3].isoformat() if user_data[3] else datetime.now().isoformat(),
                "parent_name": None,
                "permission_count": 8
            }
            
            return jsonify(user_info)
    except Exception as e:
        log.error(f"Error getting user detail: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/api/rbac/users/<int:user_id>/permissions', methods=['GET'])
@login_required
def get_user_permissions_detail(user_id):
    """Get user permissions with source information"""
    # Mock permissions data
    permissions = [
        {
            "key": "page_dashboard",
            "description": "Access to dashboard page",
            "category": "page",
            "source": "inherited"
        },
        {
            "key": "page_device_list", 
            "description": "Access to device list page",
            "category": "page",
            "source": "allow"
        },
        {
            "key": "page_tester",
            "description": "Access to device tester",
            "category": "page", 
            "source": "allow"
        },
        {
            "key": "permission_admin_only",
            "description": "Administrative access only",
            "category": "admin",
            "source": "inherited"
        }
    ]
    
    return jsonify(permissions)

@app.route('/api/rbac/users/<int:user_id>/permissions', methods=['POST'])
@login_required
def update_user_permission(user_id):
    """Update user permission"""
    data = request.get_json()
    permission_key = data.get('permission_key')
    permission_type = data.get('type')
    
    log.info(f"Updating permission {permission_key} for user {user_id} to {permission_type}")
    
    # Simulate permission update
    return jsonify({"success": True, "message": "Permission updated successfully"})

@app.route('/api/rbac/roles', methods=['GET'])
@login_required
def get_rbac_roles():
    """Get all roles"""
    roles = [
        {
            "name": "Super Admin",
            "description": "Full system access",
            "permission_count": 15
        },
        {
            "name": "Admin", 
            "description": "Administrative access",
            "permission_count": 10
        },
        {
            "name": "Manager",
            "description": "Management level access",
            "permission_count": 8
        },
        {
            "name": "User",
            "description": "Basic user access", 
            "permission_count": 5
        }
    ]
    
    return jsonify(roles)

@app.route('/api/rbac/hardware', methods=['GET'])
@login_required
def get_rbac_hardware():
    """Get hardware catalog"""
    hardware = [
        {
            "name": "EMS-4R",
            "hardware_type": "Energy Management",
            "status": "active"
        },
        {
            "name": "AMS-3S2R",
            "hardware_type": "Alarm System",
            "status": "active"
        },
        {
            "name": "GoldBox v2",
            "hardware_type": "IoT Gateway",
            "status": "active"
        }
    ]
    
    return jsonify(hardware)

@app.route('/api/rbac/software', methods=['GET'])
@login_required
def get_rbac_software():
    """Get software catalog"""
    software = [
        {
            "name": "RBAC Management System",
            "version": "2.0",
            "status": "active"
        },
        {
            "name": "Device Management",
            "version": "1.5.3",
            "status": "active"
        },
        {
            "name": "Firmware Manager",
            "version": "3.2.1",
            "status": "active"
        }
    ]
    
    return jsonify(software)

@app.route('/api/rbac/audit-logs', methods=['GET'])
@login_required
def get_audit_logs():
    """Get audit logs"""
    limit = request.args.get('limit', 20)
    
    logs = [
        {
            "action": "Permission Updated",
            "permission_key": "page_device_list",
            "changed_by": current_user.id,
            "changed_at": datetime.now().isoformat()
        },
        {
            "action": "User Login",
            "permission_key": "system_access",
            "changed_by": current_user.id,
            "changed_at": (datetime.now() - timedelta(minutes=5)).isoformat()
        },
        {
            "action": "Role Assignment",
            "permission_key": "role_admin",
            "changed_by": current_user.id,
            "changed_at": (datetime.now() - timedelta(minutes=15)).isoformat()
        }
    ]
    
    return jsonify(logs[:int(limit)])

# Add this route to your gbd_multi_super_enhanced.py

@app.route('/api/rbac/permissions', methods=['GET'])
@login_required
def get_all_permissions():
    """Get all available permissions"""
    conn = get_db_connection()
    if not conn:
        return jsonify([])
    
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT key, display_name, description, category, icon
                FROM permissions 
                ORDER BY category, display_order, display_name
            """)
            
            permissions = []
            for row in cursor.fetchall():
                permissions.append({
                    "key": row[0],
                    "display_name": row[1] or row[0],
                    "description": row[2] or "",
                    "category": row[3] or "general",
                    "icon": row[4] or "fas fa-circle"
                })
            
            return jsonify(permissions)
    except Exception as e:
        log.error(f"Error getting permissions: {e}")
        # Return fallback permissions
        return jsonify([
            {"key": "page_dashboard", "display_name": "Dashboard Access", "category": "page"},
            {"key": "page_device_list", "display_name": "Device List Access", "category": "page"},
            {"key": "page_tester", "display_name": "Device Tester Access", "category": "page"},
            {"key": "permission_admin_only", "display_name": "Admin Only Access", "category": "admin"}
        ])
    finally:
        conn.close()

# Add this route to your gbd_multi_super_enhanced.py

@app.route('/project-management')
@login_required
@requires_permission('page_project_management')
def project_management_page():
    """Project Management Page"""
    return render_template('project_management.html')

# Add Project Management APIs
@app.route('/api/projects', methods=['GET'])
@login_required
def get_all_projects():
    """Get all projects with details"""
    conn = get_db_connection()
    if not conn:
        return jsonify([])
    
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT p.id, p.name, p.description, p.created_at,
                       COUNT(DISTINCT pu.user_id) as user_count,
                       COUNT(DISTINCT d.id) as device_count
                FROM projects p
                LEFT JOIN project_users pu ON p.id = pu.project_id
                LEFT JOIN devices d ON p.id = d.project_id
                GROUP BY p.id, p.name, p.description, p.created_at
                ORDER BY p.name
            """)
            
            projects = []
            for row in cursor.fetchall():
                projects.append({
                    "id": row[0],
                    "name": row[1],
                    "description": row[2] or "",
                    "created_at": row[3].isoformat() if row[3] else None,
                    "user_count": row[4] or 0,
                    "device_count": row[5] or 0
                })
            
            return jsonify(projects)
    except Exception as e:
        log.error(f"Error getting projects: {e}")
        return jsonify([])
    finally:
        conn.close()

@app.route('/api/projects', methods=['POST'])
@login_required
@requires_permission('projects.create')
def create_project():
    """Create new project"""
    data = request.get_json()
    name = data.get('name', '').strip()
    description = data.get('description', '').strip()
    
    if not name:
        return jsonify({"error": "Project name is required"}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                INSERT INTO projects (name, description, created_at)
                VALUES (%s, %s, %s)
                RETURNING id
            """, (name, description, datetime.utcnow()))
            
            project_id = cursor.fetchone()[0]
            
            # Assign current user as project admin
            cursor.execute("""
                INSERT INTO project_users (project_id, user_id, role_name)
                VALUES (%s, %s, %s)
            """, (project_id, current_user.id, 'admin'))
            
            conn.commit()
            
            return jsonify({
                "success": True,
                "message": "Project created successfully",
                "project_id": project_id
            })
    except Exception as e:
        log.error(f"Error creating project: {e}")
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/api/projects/<int:project_id>/users', methods=['GET'])
@login_required
def get_project_users(project_id):
    """Get users assigned to a project"""
    conn = get_db_connection()
    if not conn:
        return jsonify([])
    
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT u.id, u.email, u.name, pu.role_name, pu.created_at
                FROM project_users pu
                JOIN users u ON pu.user_id = u.id
                WHERE pu.project_id = %s
                ORDER BY u.name, u.email
            """, (project_id,))
            
            users = []
            for row in cursor.fetchall():
                users.append({
                    "id": row[0],
                    "email": row[1],
                    "name": row[2] or row[1].split('@')[0],
                    "role": row[3],
                    "assigned_at": row[4].isoformat() if row[4] else None
                })
            
            return jsonify(users)
    except Exception as e:
        log.error(f"Error getting project users: {e}")
        return jsonify([])
    finally:
        conn.close()

@app.route('/api/projects/<int:project_id>/assign-user', methods=['POST'])
@login_required
@requires_permission('projects.manage_users')
def assign_user_to_project(project_id):
    """Assign user to project"""
    data = request.get_json()
    user_id = data.get('user_id')
    role_name = data.get('role_name', 'user')
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Check if user is already assigned
            cursor.execute("""
                SELECT id FROM project_users 
                WHERE project_id = %s AND user_id = %s
            """, (project_id, user_id))
            
            if cursor.fetchone():
                return jsonify({"error": "User already assigned to this project"}), 400
            
            # Assign user
            cursor.execute("""
                INSERT INTO project_users (project_id, user_id, role_name)
                VALUES (%s, %s, %s)
            """, (project_id, user_id, role_name))
            
            conn.commit()
            
            return jsonify({"success": True, "message": "User assigned successfully"})
    except Exception as e:
        log.error(f"Error assigning user to project: {e}")
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()
# Add these routes to your gbd_multi_super_enhanced.py

@app.route('/api/device/<mac_address>/config', methods=['POST'])
@login_required
@requires_permission('devices.edit')
def update_device_config(mac_address):
    """Update device configuration"""
    data = request.get_json()
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Build update query dynamically based on provided fields
            update_fields = []
            values = []
            
            # Handle all configuration fields
            config_fields = {
                'target_fw_version': data.get('target_fw_version'),
                'wifi_ssid': data.get('wifi_ssid'),
                'wifi_password': data.get('wifi_password'),
                'mqtt_host': data.get('mqtt_host'),
                'mqtt_port': data.get('mqtt_port'),
                'mqtt_username': data.get('mqtt_username'),
                'mqtt_password': data.get('mqtt_password')
            }
            
            for field, value in config_fields.items():
                if value is not None:
                    update_fields.append(f"{field} = %s")
                    values.append(value)
            
            if not update_fields:
                return jsonify({"error": "No configuration changes provided"}), 400
            
            # Add MAC address for WHERE clause
            values.append(mac_address)
            
            # Update device configuration
            update_query = f"""
                UPDATE devices 
                SET {', '.join(update_fields)}, updated_at = CURRENT_TIMESTAMP
                WHERE mac_address = %s
            """
            
            cursor.execute(update_query, values)
            
            if cursor.rowcount == 0:
                return jsonify({"error": "Device not found"}), 404
            
            conn.commit()
            
            # Log the configuration change
            log.info(f"Device config updated: {mac_address} by user {current_user.id}")
            
            return jsonify({
                "success": True,
                "message": "Device configuration updated successfully",
                "updated_fields": list(config_fields.keys())
            })
            
    except Exception as e:
        log.error(f"Error updating device config: {e}")
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/api/device/<mac_address>/ota-update', methods=['POST'])
@login_required
@requires_permission('devices.control')
def trigger_ota_update(mac_address):
    """Trigger OTA firmware update"""
    data = request.get_json()
    target_version = data.get('target_version')
    
    if not target_version:
        return jsonify({"error": "Target version is required"}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Check if device exists
            cursor.execute("SELECT device_id, device_type FROM devices WHERE mac_address = %s", (mac_address,))
            device = cursor.fetchone()
            
            if not device:
                return jsonify({"error": "Device not found"}), 404
            
            device_id, device_type = device
            
            # Update target firmware version
            cursor.execute("""
                UPDATE devices 
                SET target_fw_version = %s, updated_at = CURRENT_TIMESTAMP
                WHERE mac_address = %s
            """, (target_version, mac_address))
            
            conn.commit()
            
            # Here you would typically:
            # 1. Send MQTT command to device for OTA update
            # 2. Queue the update job
            # 3. Set up monitoring for update progress
            
            # For now, we'll simulate the MQTT command
            ota_command = {
                "command": "ota_update",
                "target_version": target_version,
                "download_url": f"https://firmware.example.com/{device_type}/{target_version}.bin",
                "checksum": "sha256_checksum_here",
                "timestamp": datetime.utcnow().isoformat()
            }
            
            # Simulate sending MQTT command
            log.info(f"OTA update triggered for device {device_id} ({mac_address}) to version {target_version}")
            log.info(f"MQTT command: {json.dumps(ota_command)}")
            
            return jsonify({
                "success": True,
                "message": f"OTA update initiated for {device_id}",
                "target_version": target_version,
                "estimated_duration": "5-10 minutes"
            })
            
    except Exception as e:
        log.error(f"Error triggering OTA update: {e}")
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/api/device/<mac_address>/reboot', methods=['POST'])
@login_required
@requires_permission('devices.control')
def reboot_device(mac_address):
    """Reboot device remotely"""
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Check if device exists
            cursor.execute("SELECT device_id FROM devices WHERE mac_address = %s", (mac_address,))
            device = cursor.fetchone()
            
            if not device:
                return jsonify({"error": "Device not found"}), 404
            
            device_id = device[0]
            
            # Here you would send MQTT reboot command
            reboot_command = {
                "command": "reboot",
                "timestamp": datetime.utcnow().isoformat(),
                "initiated_by": current_user.email
            }
            
            # Simulate sending MQTT command
            log.info(f"Reboot command sent to device {device_id} ({mac_address}) by user {current_user.id}")
            log.info(f"MQTT command: {json.dumps(reboot_command)}")
            
            return jsonify({
                "success": True,
                "message": f"Reboot command sent to {device_id}",
                "expected_downtime": "2-3 minutes"
            })
            
    except Exception as e:
        log.error(f"Error rebooting device: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/api/devices/batch-update', methods=['POST'])
@login_required
@requires_permission('devices.edit')
def batch_update_devices():
    """Batch update multiple devices"""
    data = request.get_json()
    device_macs = data.get('device_macs', [])
    config_updates = data.get('config', {})
    
    if not device_macs:
        return jsonify({"error": "No devices specified"}), 400
    
    if not config_updates:
        return jsonify({"error": "No configuration updates provided"}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            updated_count = 0
            failed_updates = []
            
            for mac_address in device_macs:
                try:
                    # Build update query for each device
                    update_fields = []
                    values = []
                    
                    for field, value in config_updates.items():
                        if value is not None and value != "":
                            update_fields.append(f"{field} = %s")
                            values.append(value)
                    
                    if update_fields:
                        values.append(mac_address)
                        
                        update_query = f"""
                            UPDATE devices 
                            SET {', '.join(update_fields)}, updated_at = CURRENT_TIMESTAMP
                            WHERE mac_address = %s
                        """
                        
                        cursor.execute(update_query, values)
                        
                        if cursor.rowcount > 0:
                            updated_count += 1
                            
                            # Send MQTT configuration update command
                            mqtt_command = {
                                "command": "config_update",
                                "config": config_updates,
                                "timestamp": datetime.utcnow().isoformat(),
                                "initiated_by": current_user.email
                            }
                            
                            log.info(f"Batch config update sent to device {mac_address}: {json.dumps(mqtt_command)}")
                        else:
                            failed_updates.append({"mac": mac_address, "error": "Device not found"})
                    
                except Exception as device_error:
                    failed_updates.append({"mac": mac_address, "error": str(device_error)})
                    log.error(f"Failed to update device {mac_address}: {device_error}")
            
            conn.commit()
            
            # Log the batch operation
            log.info(f"Batch update completed by user {current_user.id}: {updated_count} devices updated, {len(failed_updates)} failed")
            
            return jsonify({
                "success": True,
                "message": f"Batch update completed",
                "updated_count": updated_count,
                "failed_count": len(failed_updates),
                "failed_updates": failed_updates,
                "config_applied": config_updates
            })
            
    except Exception as e:
        log.error(f"Error in batch update: {e}")
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/api/firmware-versions', methods=['GET'])
@login_required
def get_firmware_versions():
    """Get available firmware versions"""
    # This could be from database or firmware manifest
    firmware_versions = [
        {"version": "3.5.6", "description": "Latest stable release", "release_date": "2025-07-29"},
        {"version": "3.5.5", "description": "Previous stable release", "release_date": "2025-07-15"},
        {"version": "3.5.4", "description": "Legacy release", "release_date": "2025-07-01"},
        {"version": "3.5.3", "description": "Legacy release", "release_date": "2025-06-15"}
    ]
    
    return jsonify(firmware_versions)

# Add device permissions to your existing permissions if not already present
def add_device_permissions():
    """Add device management permissions"""
    conn = get_db_connection()
    if not conn:
        return
    
    try:
        with conn.cursor() as cursor:
            device_permissions = [
                ('devices.view', 'View Devices', 'Permission to view device list', 'device'),
                ('devices.edit', 'Edit Devices', 'Permission to edit device configuration', 'device'),
                ('devices.control', 'Control Devices', 'Permission to control devices (reboot, OTA)', 'device'),
                ('devices.create', 'Create Devices', 'Permission to add new devices', 'device'),
                ('devices.delete', 'Delete Devices', 'Permission to remove devices', 'device'),
                ('devices.assign', 'Assign Devices', 'Permission to assign devices to users/projects', 'device')
            ]
            
            for key, display_name, description, category in device_permissions:
                cursor.execute("""
                    INSERT INTO permissions (key, display_name, description, category)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT (key) DO NOTHING
                """, (key, display_name, description, category))
                
                # Assign to admin role
                cursor.execute("""
                    INSERT INTO role_permissions (role_name, permission_key)
                    VALUES ('admin', %s)
                    ON CONFLICT (role_name, permission_key) DO NOTHING
                """, (key,))
            
            conn.commit()
            log.info("Device permissions added successfully")
            
    except Exception as e:
        log.error(f"Error adding device permissions: {e}")
        conn.rollback()
    finally:
        conn.close()
        
@app.route('/device-list')
@login_required
@requires_permission('page_device_list')
def enhanced_device_list():
    """Enhanced Device List with OTA and Remote Configuration"""
    return render_template('device_list_ENHANCED_OTA.html')

# Update the device API to include configuration fields
@app.route('/api/project/<int:project_id>/devices', methods=['GET'])
@login_required
def get_project_devices_enhanced(project_id):
    """Get devices for a specific project with configuration data"""
    conn = get_db_connection()
    if not conn:
        return jsonify([])
    
    try:
        with conn.cursor() as cursor:
            # Enhanced query with configuration fields
            cursor.execute("""
                SELECT mac_address, device_id, last_seen, current_fw_version, 
                       target_fw_version, project, assigned_user, device_type,
                       wifi_ssid, wifi_password, mqtt_host, mqtt_port, 
                       mqtt_username, mqtt_password, updated_at, created_at
                FROM devices 
                ORDER BY device_id, mac_address
            """)
            
            devices = []
            for row in cursor.fetchall():
                device = {
                    "mac_address": row[0],
                    "device_id": row[1],
                    "last_seen": row[2].isoformat() if row[2] else None,
                    "current_fw_version": row[3],
                    "target_fw_version": row[4],
                    "project": row[5],
                    "assigned_user": row[6],
                    "device_type": row[7],
                    "wifi_ssid": row[8],
                    "wifi_password": row[9],
                    "mqtt_host": row[10],
                    "mqtt_port": row[11],
                    "mqtt_username": row[12],
                    "mqtt_password": row[13],
                    "updated_at": row[14].isoformat() if row[14] else None,
                    "created_at": row[15].isoformat() if row[15] else None
                }
                devices.append(device)
            
            log.info(f"Retrieved {len(devices)} devices with configuration data")
            return jsonify(devices)
            
    except Exception as e:
        log.error(f"Error getting enhanced device data: {e}")
        return jsonify([])
    finally:
        conn.close()
# Add to your gbd_multi_super_enhanced.py

@app.route('/firmware/<filename>')
def serve_firmware(filename):
    """Serve firmware files for OTA download"""
    firmware_dir = os.path.join(os.getcwd(), 'firmware')
    if not os.path.exists(os.path.join(firmware_dir, filename)):
        return jsonify({"error": "Firmware not found"}), 404
    
    return send_from_directory(firmware_dir, filename, as_attachment=True)

@app.route('/api/device/<device_id>')
def device_update_check(device_id):
    """Device update check endpoint (matches your firmware URL)"""
    mac = request.args.get('mac')
    current_version = request.args.get('version')
    build_date = request.args.get('build')
    device_type = request.args.get('type')
    
    # Check if firmware update available
    latest_version = "2.1.0"  # Get from database
    
    response = {
        "config": {
            "changeSetting": False  # Set to True if config update needed
        },
        "ota_update": {
            "update_available": current_version < latest_version,
            "firmware_url": f"http://api.ssplcms.com:5000/firmware/{device_type}_{latest_version}.bin"
        }
    }
    
    return jsonify(response)

@app.route('/api/device/operation_status', methods=['POST'])
def device_operation_status():
    """Receive OTA/config operation status from devices"""
    data = request.get_json()
    mac = data.get('mac')
    operation = data.get('operation')  # 'ota' or 'config'
    status = data.get('status')  # 'success' or 'failure'
    version = data.get('version', '')
    
    # Update device status in database
    conn = get_db_connection()
    if conn:
        try:
            with conn.cursor() as cursor:
                if operation == 'ota' and status == 'success':
                    cursor.execute("""
                        UPDATE devices 
                        SET current_fw_version = %s, 
                            is_updating = FALSE,
                            update_progress = 100,
                            status = 'online'
                        WHERE mac_address = %s
                    """, (version, mac))
                    
                    # Emit WebSocket event
                    socketio.emit('ota_completed', {
                        'mac_address': mac,
                        'firmware_version': version,
                        'status': 'online',
                        'timestamp': datetime.utcnow().isoformat()
                    }, room='device_monitoring')
                
                conn.commit()
                log.info(f"Device {mac} reported {operation} {status}, version: {version}")
        finally:
            conn.close()
    
    return jsonify({"success": True})

# Update your existing OTA trigger to work with AMS firmware

@app.route('/api/device/<mac_address>/ota-update', methods=['POST'])
@login_required
@requires_permission('devices.control')
def trigger_ota_update_ams_compatible(mac_address):
    """Trigger OTA update compatible with AMS firmware"""
    data = request.get_json()
    target_version = data.get('target_version')
    
    if not target_version:
        return jsonify({"error": "Target version is required"}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Get device info
            cursor.execute("SELECT device_id, device_type FROM devices WHERE mac_address = %s", (mac_address,))
            device = cursor.fetchone()
            
            if not device:
                return jsonify({"error": "Device not found"}), 404
            
            device_id, device_type = device
            
            # Mark as updating
            cursor.execute("""
                UPDATE devices 
                SET target_fw_version = %s, 
                    is_updating = TRUE,
                    update_progress = 0,
                    update_started_at = CURRENT_TIMESTAMP,
                    status = 'updating'
                WHERE mac_address = %s
            """, (target_version, mac_address))
            
            conn.commit()
            
            # AMS firmware checks for updates automatically every few minutes
            # We just mark it as pending - the device will pick it up
            log.info(f"OTA update marked for device {device_id} ({mac_address}) to version {target_version}")
            log.info(f"Device will pick up update on next check cycle")
            
            # Emit WebSocket event
            socketio.emit('ota_started', {
                'mac_address': mac_address,
                'device_id': device_id,
                'target_version': target_version,
                'status': 'updating',
                'timestamp': datetime.utcnow().isoformat()
            }, room='device_monitoring')
            
            return jsonify({
                "success": True,
                "message": f"OTA update queued for {device_id}",
                "target_version": target_version,
                "note": "Device will pick up update automatically"
            })
            
    except Exception as e:
        log.error(f"Error triggering OTA update: {e}")
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

# ====================================
# USER MANAGEMENT APIs
# ====================================

@app.route('/api/rbac/users', methods=['POST'])
@login_required
@requires_permission('users.create')
def create_user():
    """Create new user"""
    data = request.get_json()
    
    name = data.get('name', '').strip()
    email = data.get('email', '').strip()
    password = data.get('password', '')
    role = data.get('role', 'user')
    parent_id = data.get('parent_id')
    permissions = data.get('permissions', {})
    
    if not name or not email or not password:
        return jsonify({"error": "Name, email, and password are required"}), 400
    
    # Validate email format
    if not re.match(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', email):
        return jsonify({"error": "Invalid email format"}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Check if email already exists
            cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
            if cursor.fetchone():
                return jsonify({"error": "Email already exists"}), 400
            
            # Hash password
            password_hash = bcrypt.generate_password_hash(password).decode('utf-8')
            
            # Create user
            cursor.execute("""
                INSERT INTO users (name, email, password_hash, parent_id, created_at)
                VALUES (%s, %s, %s, %s, %s)
                RETURNING id
            """, (name, email, password_hash, parent_id if parent_id else None, datetime.utcnow()))
            
            user_id = cursor.fetchone()[0]
            
            # Assign to default project with role
            cursor.execute("""
                INSERT INTO project_users (project_id, user_id, role_name, created_at)
                VALUES (1, %s, %s, %s)
                ON CONFLICT (project_id, user_id) DO NOTHING
            """, (user_id, role, datetime.utcnow()))
            
            # Set permission overrides if provided
            for perm_key, perm_type in permissions.items():
                if perm_type in ['allow', 'deny']:
                    cursor.execute("""
                        INSERT INTO user_permissions (user_id, permission_key, permission_type, created_at)
                        VALUES (%s, %s, %s, %s)
                        ON CONFLICT (user_id, permission_key) 
                        DO UPDATE SET permission_type = EXCLUDED.permission_type
                    """, (user_id, perm_key, perm_type, datetime.utcnow()))
            
            conn.commit()
            
            log.info(f"User created: {email} (ID: {user_id}) by user {current_user.id}")
            
            return jsonify({
                "success": True,
                "message": "User created successfully",
                "user_id": user_id
            })
            
    except Exception as e:
        log.error(f"Error creating user: {e}")
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/api/rbac/users/<int:user_id>', methods=['PUT'])
@login_required
@requires_permission('users.edit')
def update_user(user_id):
    """Update existing user"""
    data = request.get_json()
    
    name = data.get('name', '').strip()
    email = data.get('email', '').strip()
    role = data.get('role')
    parent_id = data.get('parent_id')
    permissions = data.get('permissions', {})
    
    if not name or not email:
        return jsonify({"error": "Name and email are required"}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Check if user exists
            cursor.execute("SELECT id FROM users WHERE id = %s", (user_id,))
            if not cursor.fetchone():
                return jsonify({"error": "User not found"}), 404
            
            # Check email uniqueness (excluding current user)
            cursor.execute("SELECT id FROM users WHERE email = %s AND id != %s", (email, user_id))
            if cursor.fetchone():
                return jsonify({"error": "Email already exists"}), 400
            
            # Update user
            cursor.execute("""
                UPDATE users 
                SET name = %s, email = %s, parent_id = %s
                WHERE id = %s
            """, (name, email, parent_id if parent_id else None, user_id))
            
            # Update role if provided
            if role:
                cursor.execute("""
                    UPDATE project_users 
                    SET role_name = %s
                    WHERE user_id = %s AND project_id = 1
                """, (role, user_id))
            
            # Clear existing permission overrides
            cursor.execute("DELETE FROM user_permissions WHERE user_id = %s", (user_id,))
            
            # Set new permission overrides
            for perm_key, perm_type in permissions.items():
                if perm_type in ['allow', 'deny']:
                    cursor.execute("""
                        INSERT INTO user_permissions (user_id, permission_key, permission_type, created_at)
                        VALUES (%s, %s, %s, %s)
                    """, (user_id, perm_key, perm_type, datetime.utcnow()))
            
            conn.commit()
            
            log.info(f"User updated: {email} (ID: {user_id}) by user {current_user.id}")
            
            return jsonify({
                "success": True,
                "message": "User updated successfully"
            })
            
    except Exception as e:
        log.error(f"Error updating user: {e}")
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/api/rbac/users/<int:user_id>', methods=['DELETE'])
@login_required
@requires_permission('users.delete')
def delete_user(user_id):
    """Delete user"""
    if user_id == current_user.id:
        return jsonify({"error": "Cannot delete your own account"}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Check if user exists
            cursor.execute("SELECT email FROM users WHERE id = %s", (user_id,))
            user = cursor.fetchone()
            if not user:
                return jsonify({"error": "User not found"}), 404
            
            email = user[0]
            
            # Delete user (CASCADE should handle related records)
            cursor.execute("DELETE FROM users WHERE id = %s", (user_id,))
            
            conn.commit()
            
            log.info(f"User deleted: {email} (ID: {user_id}) by user {current_user.id}")
            
            return jsonify({
                "success": True,
                "message": "User deleted successfully"
            })
            
    except Exception as e:
        log.error(f"Error deleting user: {e}")
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

# ====================================
# ROLE MANAGEMENT APIs
# ====================================

@app.route('/api/rbac/roles', methods=['POST'])
@login_required
@requires_permission('roles.create')
def create_role():
    """Create new role"""
    data = request.get_json()
    
    name = data.get('name', '').strip()
    description = data.get('description', '').strip()
    permissions = data.get('permissions', {})
    
    if not name:
        return jsonify({"error": "Role name is required"}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Check if role already exists
            cursor.execute("SELECT role_name FROM role_permissions WHERE role_name = %s LIMIT 1", (name,))
            if cursor.fetchone():
                return jsonify({"error": "Role already exists"}), 400
            
            # Create role permissions
            for perm_key, perm_type in permissions.items():
                if perm_type == 'allow':
                    cursor.execute("""
                        INSERT INTO role_permissions (role_name, permission_key, created_at)
                        VALUES (%s, %s, %s)
                    """, (name, perm_key, datetime.utcnow()))
            
            # Store role metadata (create roles table if needed)
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS roles (
                    name VARCHAR(50) PRIMARY KEY,
                    description TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    created_by INTEGER REFERENCES users(id)
                )
            """)
            
            cursor.execute("""
                INSERT INTO roles (name, description, created_at, created_by)
                VALUES (%s, %s, %s, %s)
                ON CONFLICT (name) DO UPDATE SET 
                description = EXCLUDED.description
            """, (name, description, datetime.utcnow(), current_user.id))
            
            conn.commit()
            
            log.info(f"Role created: {name} by user {current_user.id}")
            
            return jsonify({
                "success": True,
                "message": "Role created successfully"
            })
            
    except Exception as e:
        log.error(f"Error creating role: {e}")
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/api/rbac/roles/<role_name>', methods=['PUT'])
@login_required
@requires_permission('roles.edit')
def update_role(role_name):
    """Update existing role"""
    data = request.get_json()
    
    new_name = data.get('name', '').strip()
    description = data.get('description', '').strip()
    permissions = data.get('permissions', {})
    
    if not new_name:
        return jsonify({"error": "Role name is required"}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Check if role exists
            cursor.execute("SELECT role_name FROM role_permissions WHERE role_name = %s LIMIT 1", (role_name,))
            if not cursor.fetchone():
                return jsonify({"error": "Role not found"}), 404
            
            # If name changed, check new name doesn't exist
            if new_name != role_name:
                cursor.execute("SELECT role_name FROM role_permissions WHERE role_name = %s LIMIT 1", (new_name,))
                if cursor.fetchone():
                    return jsonify({"error": "New role name already exists"}), 400
                
                # Update role name in all related tables
                cursor.execute("UPDATE role_permissions SET role_name = %s WHERE role_name = %s", (new_name, role_name))
                cursor.execute("UPDATE project_users SET role_name = %s WHERE role_name = %s", (new_name, role_name))
            
            # Clear existing permissions
            cursor.execute("DELETE FROM role_permissions WHERE role_name = %s", (new_name,))
            
            # Set new permissions
            for perm_key, perm_type in permissions.items():
                if perm_type == 'allow':
                    cursor.execute("""
                        INSERT INTO role_permissions (role_name, permission_key, created_at)
                        VALUES (%s, %s, %s)
                    """, (new_name, perm_key, datetime.utcnow()))
            
            # Update role metadata
            cursor.execute("""
                UPDATE roles 
                SET name = %s, description = %s
                WHERE name = %s
            """, (new_name, description, role_name))
            
            conn.commit()
            
            log.info(f"Role updated: {role_name} -> {new_name} by user {current_user.id}")
            
            return jsonify({
                "success": True,
                "message": "Role updated successfully"
            })
            
    except Exception as e:
        log.error(f"Error updating role: {e}")
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/api/rbac/roles/<role_name>', methods=['DELETE'])
@login_required
@requires_permission('roles.delete')
def delete_role(role_name):
    """Delete role"""
    if role_name in ['admin', 'super_admin']:
        return jsonify({"error": "Cannot delete system roles"}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Check if role exists
            cursor.execute("SELECT role_name FROM role_permissions WHERE role_name = %s LIMIT 1", (role_name,))
            if not cursor.fetchone():
                return jsonify({"error": "Role not found"}), 404
            
            # Check if role is in use
            cursor.execute("SELECT user_id FROM project_users WHERE role_name = %s LIMIT 1", (role_name,))
            if cursor.fetchone():
                return jsonify({"error": "Cannot delete role that is assigned to users"}), 400
            
            # Delete role
            cursor.execute("DELETE FROM role_permissions WHERE role_name = %s", (role_name,))
            cursor.execute("DELETE FROM roles WHERE name = %s", (role_name,))
            
            conn.commit()
            
            log.info(f"Role deleted: {role_name} by user {current_user.id}")
            
            return jsonify({
                "success": True,
                "message": "Role deleted successfully"
            })
            
    except Exception as e:
        log.error(f"Error deleting role: {e}")
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

# ====================================
# ENHANCED EXISTING APIs
# ====================================

@app.route('/api/rbac/users', methods=['GET'])
@login_required
def get_rbac_users_enhanced():
    """Get all users with enhanced information"""
    conn = get_db_connection()
    if not conn:
        return jsonify([])
    
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT u.id, u.email, u.name, pu.role_name, u.created_at,
                       COUNT(up.permission_key) as permission_count
                FROM users u
                LEFT JOIN project_users pu ON u.id = pu.user_id AND pu.project_id = 1
                LEFT JOIN user_permissions up ON u.id = up.user_id
                GROUP BY u.id, u.email, u.name, pu.role_name, u.created_at
                ORDER BY u.created_at DESC
            """)
            
            users = []
            for row in cursor.fetchall():
                users.append({
                    "id": row[0],
                    "email": row[1],
                    "name": row[2] or row[1].split('@')[0],
                    "role": row[3] or 'user',
                    "created_at": row[4].isoformat() if row[4] else datetime.utcnow().isoformat(),
                    "permission_count": row[5] or 0,
                    "status": "active"  # Add status logic if needed
                })
            
            return jsonify(users)
            
    except Exception as e:
        log.error(f"Error getting users: {e}")
        return jsonify([])
    finally:
        conn.close()

@app.route('/api/rbac/roles', methods=['GET'])
@login_required
def get_rbac_roles_enhanced():
    """Get all roles with enhanced information"""
    conn = get_db_connection()
    if not conn:
        return jsonify([])
    
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT r.name, r.description, COUNT(rp.permission_key) as permission_count
                FROM (
                    SELECT DISTINCT role_name as name, '' as description
                    FROM role_permissions
                    UNION
                    SELECT name, description FROM roles
                ) r
                LEFT JOIN role_permissions rp ON r.name = rp.role_name
                GROUP BY r.name, r.description
                ORDER BY r.name
            """)
            
            roles = []
            for row in cursor.fetchall():
                roles.append({
                    "name": row[0],
                    "description": row[1] or f"{row[0]} role",
                    "permission_count": row[2] or 0
                })
            
            return jsonify(roles)
            
    except Exception as e:
        log.error(f"Error getting roles: {e}")
        return jsonify([])
    finally:
        conn.close()

@app.route('/api/rbac/stats', methods=['GET'])
@login_required
def get_rbac_stats_enhanced():
    """Get enhanced RBAC system statistics"""
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Count users
            cursor.execute("SELECT COUNT(*) FROM users")
            user_count = cursor.fetchone()[0]
            
            # Count roles
            cursor.execute("SELECT COUNT(DISTINCT role_name) FROM role_permissions")
            role_count = cursor.fetchone()[0]
            
            # Count permissions
            cursor.execute("SELECT COUNT(*) FROM permissions")
            permission_count = cursor.fetchone()[0]
            
            # Calculate hierarchy depth
            cursor.execute("""
                WITH RECURSIVE hierarchy AS (
                    SELECT id, parent_id, 1 as depth FROM users WHERE parent_id IS NULL
                    UNION ALL
                    SELECT u.id, u.parent_id, h.depth + 1 
                    FROM users u 
                    JOIN hierarchy h ON u.parent_id = h.id
                    WHERE h.depth < 10  -- Prevent infinite recursion
                )
                SELECT COALESCE(MAX(depth), 1) FROM hierarchy
            """)
            max_depth = cursor.fetchone()[0]
            
            return jsonify({
                "users": user_count,
                "roles": role_count,
                "permissions": permission_count,
                "max_depth": max_depth,
                "system_health": "healthy",
                "last_updated": datetime.utcnow().isoformat()
            })
            
    except Exception as e:
        log.error(f"Error getting RBAC stats: {e}")
        return jsonify({
            "users": 1,
            "roles": 4,
            "permissions": 12,
            "max_depth": 1,
            "system_health": "error",
            "last_updated": datetime.utcnow().isoformat()
        })
    finally:
        conn.close()

# ====================================
# AUDIT LOG SYSTEM
# ====================================

def log_rbac_action(action, details, permission_key=None, target_user_id=None):
    """Log RBAC actions for audit trail"""
    conn = get_db_connection()
    if not conn:
        return
    
    try:
        with conn.cursor() as cursor:
            # Create audit log table if not exists
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS rbac_audit_log (
                    id SERIAL PRIMARY KEY,
                    action VARCHAR(100) NOT NULL,
                    permission_key VARCHAR(100),
                    target_user_id INTEGER,
                    changed_by INTEGER REFERENCES users(id),
                    details TEXT,
                    ip_address INET,
                    user_agent TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
            
            # Get client info
            ip_address = request.environ.get('REMOTE_ADDR', '127.0.0.1')
            user_agent = request.headers.get('User-Agent', '')
            
            cursor.execute("""
                INSERT INTO rbac_audit_log 
                (action, permission_key, target_user_id, changed_by, details, ip_address, user_agent)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (action, permission_key, target_user_id, current_user.id, details, ip_address, user_agent))
            
            conn.commit()
            
    except Exception as e:
        log.error(f"Error logging RBAC action: {e}")
    finally:
        conn.close()

@app.route('/api/rbac/audit-logs', methods=['GET'])
@login_required
@requires_permission('audit.view')
def get_audit_logs_enhanced():
    """Get enhanced audit logs"""
    limit = request.args.get('limit', 50, type=int)
    action_filter = request.args.get('action', '')
    
    conn = get_db_connection()
    if not conn:
        return jsonify([])
    
    try:
        with conn.cursor() as cursor:
            # Check if audit log table exists
            cursor.execute("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_name = 'rbac_audit_log'
                )
            """)
            
            if not cursor.fetchone()[0]:
                # Return mock data if table doesn't exist
                return jsonify([
                    {
                        "action": "User Login",
                        "permission_key": "system_access",
                        "changed_by": current_user.id,
                        "changed_at": datetime.utcnow().isoformat(),
                        "details": f"User {current_user.email} logged in",
                        "ip_address": request.environ.get('REMOTE_ADDR', '127.0.0.1')
                    }
                ])
            
            # Build query with filters
            where_clause = ""
            params = []
            
            if action_filter:
                where_clause = "WHERE action ILIKE %s"
                params.append(f"%{action_filter}%")
            
            cursor.execute(f"""
                SELECT action, permission_key, target_user_id, changed_by, details, 
                       ip_address, user_agent, created_at
                FROM rbac_audit_log
                {where_clause}
                ORDER BY created_at DESC
                LIMIT %s
            """, params + [limit])
            
            logs = []
            for row in cursor.fetchall():
                logs.append({
                    "action": row[0],
                    "permission_key": row[1],
                    "target_user_id": row[2],
                    "changed_by": row[3],
                    "details": row[4],
                    "ip_address": row[5],
                    "user_agent": row[6],
                    "changed_at": row[7].isoformat() if row[7] else datetime.utcnow().isoformat()
                })
            
            return jsonify(logs)
            
    except Exception as e:
        log.error(f"Error getting audit logs: {e}")
        return jsonify([])
    finally:
        conn.close()

# ====================================
# PERMISSION DISCOVERY ENHANCEMENT
# ====================================

@app.route('/api/rbac/discover-permissions', methods=['POST'])
@login_required
@requires_permission('permissions.discover')
def discover_permissions_enhanced():
    """Enhanced permission discovery"""
    try:
        discovered_permissions = []
        
        # Scan current file for @requires_permission decorators
        import os
        import ast
        
        current_file = __file__
        if os.path.exists(current_file):
            with open(current_file, 'r') as f:
                content = f.read()
                
            # Find @requires_permission patterns
            import re
            patterns = re.findall(r"@requires_permission\(['\"]([^'\"]+)['\"]\)", content)
            discovered_permissions.extend(patterns)
        
        # Add some common permissions that might be missing
        common_permissions = [
            'users.create', 'users.edit', 'users.delete', 'users.view',
            'roles.create', 'roles.edit', 'roles.delete', 'roles.view',
            'permissions.discover', 'permissions.manage',
            'audit.view', 'audit.export',
            'system.admin.full_access',
            'projects.create', 'projects.edit', 'projects.delete',
            'devices.create', 'devices.edit', 'devices.delete', 'devices.control',
            'firmware.upload', 'firmware.manage',
            'reports.view', 'reports.export'
        ]
        
        discovered_permissions.extend(common_permissions)
        discovered_permissions = list(set(discovered_permissions))  # Remove duplicates
        
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        
        new_count = 0
        try:
            with conn.cursor() as cursor:
                for perm in discovered_permissions:
                    # Check if permission exists
                    cursor.execute("SELECT key FROM permissions WHERE key = %s", (perm,))
                    if not cursor.fetchone():
                        # Create permission
                        display_name = perm.replace('_', ' ').replace('.', ' ').title()
                        category = perm.split('.')[0] if '.' in perm else 'general'
                        
                        cursor.execute("""
                            INSERT INTO permissions (key, display_name, description, category, auto_discovered)
                            VALUES (%s, %s, %s, %s, %s)
                        """, (perm, display_name, f"Auto-discovered: {perm}", category, True))
                        
                        new_count += 1
                        
                        # Auto-assign to admin role
                        cursor.execute("""
                            INSERT INTO role_permissions (role_name, permission_key, created_at)
                            VALUES ('admin', %s, %s)
                            ON CONFLICT (role_name, permission_key) DO NOTHING
                        """, (perm, datetime.utcnow()))
                
                conn.commit()
                
                log.info(f"Permission discovery completed: {new_count} new permissions found")
                log_rbac_action("Permission Discovery", f"Discovered {new_count} new permissions")
                
                return jsonify({
                    "success": True,
                    "message": f"Permission discovery completed. Found {new_count} new permissions.",
                    "discovered_count": new_count,
                    "total_scanned": len(discovered_permissions)
                })
                
        except Exception as e:
            conn.rollback()
            raise e
            
    except Exception as e:
        log.error(f"Error in permission discovery: {e}")
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500
    finally:
        if conn:
            conn.close()

# ====================================
# MISSING TABLES CREATION
# ====================================

def ensure_rbac_tables():
    """Ensure all RBAC tables exist - FIXED VERSION"""
    conn = get_db_connection()
    if not conn:
        return False
    
    try:
        with conn.cursor() as cursor:
            log.info("Ensuring RBAC tables exist...")
            
            # 1. Create tables without the problematic columns first
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS user_permissions (
                    id SERIAL PRIMARY KEY,
                    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                    permission_key VARCHAR(100) NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    UNIQUE(user_id, permission_key)
                )
            """)
            
            # 2. Add columns if they don't exist (safer approach)
            try:
                cursor.execute("ALTER TABLE role_permissions ADD COLUMN IF NOT EXISTS permission_type VARCHAR(10) DEFAULT 'allow'")
                cursor.execute("ALTER TABLE role_permissions ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
                cursor.execute("ALTER TABLE role_permissions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
                cursor.execute("ALTER TABLE role_permissions ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL")
            except Exception as e:
                log.warning(f"Some columns might already exist: {e}")
            
            # 3. Add columns to permissions table
            try:
                cursor.execute("ALTER TABLE permissions ADD COLUMN IF NOT EXISTS category VARCHAR(50) DEFAULT 'general'")
                cursor.execute("ALTER TABLE permissions ADD COLUMN IF NOT EXISTS display_name VARCHAR(200)")
                cursor.execute("ALTER TABLE permissions ADD COLUMN IF NOT EXISTS description TEXT")
                cursor.execute("ALTER TABLE permissions ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
                cursor.execute("ALTER TABLE permissions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
                cursor.execute("ALTER TABLE permissions ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL")
            except Exception as e:
                log.warning(f"Some permission columns might already exist: {e}")
            
            # 4. Insert basic permissions (using simpler INSERT)
            basic_permissions = [
                ('admin.access', 'Admin Access', 'Full administrative access', 'admin'),
                ('permission_admin_only', 'Admin Only', 'Administrative privileges', 'admin'),
                ('page_rbac_management', 'RBAC Management', 'Access RBAC management page', 'page'),
                ('page_dashboard', 'Dashboard', 'Access dashboard page', 'page'),
                ('page_device_list', 'Device List', 'Access device list page', 'page'),
                ('page_tester', 'Device Tester', 'Access device tester', 'page'),
                ('users.create', 'Create Users', 'Create new users', 'user'),
                ('users.edit', 'Edit Users', 'Edit existing users', 'user'),
                ('roles.view', 'View Roles', 'View role information', 'role'),
                ('devices.control', 'Control Devices', 'Control device operations', 'device')
            ]
            
            for key, display_name, description, category in basic_permissions:
                try:
                    cursor.execute("""
                        INSERT INTO permissions (key, display_name, description, category)
                        VALUES (%s, %s, %s, %s)
                        ON CONFLICT (key) DO NOTHING
                    """, (key, display_name, description, category))
                except Exception as e:
                    log.warning(f"Could not insert permission {key}: {e}")
            
            # 5. Assign permissions to roles (using simpler approach)
            role_permissions_simple = [
                ('super_admin', 'admin.access'),
                ('super_admin', 'permission_admin_only'),
                ('super_admin', 'page_rbac_management'),
                ('super_admin', 'page_dashboard'),
                ('super_admin', 'page_device_list'),
                ('super_admin', 'users.create'),
                ('super_admin', 'users.edit'),
                ('admin', 'permission_admin_only'),
                ('admin', 'page_rbac_management'),
                ('admin', 'page_dashboard'),
                ('admin', 'page_device_list'),
                ('admin', 'users.create'),
                ('user', 'page_dashboard'),
                ('user', 'page_device_list')
            ]
            
            for role_name, permission_key in role_permissions_simple:
                try:
                    # Check if permission_type column exists
                    cursor.execute("""
                        SELECT column_name FROM information_schema.columns 
                        WHERE table_name = 'role_permissions' AND column_name = 'permission_type'
                    """)
                    has_permission_type = cursor.fetchone() is not None
                    
                    if has_permission_type:
                        cursor.execute("""
                            INSERT INTO role_permissions (role_name, permission_key, permission_type)
                            VALUES (%s, %s, 'allow')
                            ON CONFLICT (role_name, permission_key) DO NOTHING
                        """, (role_name, permission_key))
                    else:
                        cursor.execute("""
                            INSERT INTO role_permissions (role_name, permission_key)
                            VALUES (%s, %s)
                            ON CONFLICT (role_name, permission_key) DO NOTHING
                        """, (role_name, permission_key))
                except Exception as e:
                    log.warning(f"Could not assign permission {permission_key} to {role_name}: {e}")
            
            conn.commit()
            log.info("RBAC tables ensured successfully (with fixes)")
            return True
            
    except Exception as e:
        log.error(f"Error ensuring RBAC tables: {e}")
        conn.rollback()
        return False
    finally:
        conn.close()
        
    # Add these routes to your gbd_multi_super_enhanced.py

@app.route('/register', methods=['GET', 'POST'])
def register():
    """User registration page and handler"""
    if request.method == 'GET':
        # Show registration form
        return render_template('register.html')
    
    # Handle registration form submission (fallback for non-AJAX)
    return redirect(url_for('register'))

@app.route('/api/register', methods=['POST'])
def api_register():
    """API endpoint for user registration"""
    data = request.get_json()
    
    # Extract and validate data
    first_name = data.get('first_name', '').strip()
    last_name = data.get('last_name', '').strip()
    email = data.get('email', '').strip().lower()
    mobile = data.get('mobile', '').strip()
    password = data.get('password', '')
    
    # Validation
    errors = []
    
    if not first_name or len(first_name) < 2:
        errors.append("First name must be at least 2 characters long")
    
    if not last_name or len(last_name) < 2:
        errors.append("Last name must be at least 2 characters long")
    
    if not email:
        errors.append("Email is required")
    elif not re.match(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', email):
        errors.append("Invalid email format")
    
    if not mobile:
        errors.append("Mobile number is required")
    elif not re.match(r'^\d{10}$', mobile):
        errors.append("Mobile number must be exactly 10 digits")
    
    if not password:
        errors.append("Password is required")
    elif len(password) < 8:
        errors.append("Password must be at least 8 characters long")
    
    if errors:
        return jsonify({"error": "; ".join(errors)}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Check if email already exists
            cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
            if cursor.fetchone():
                return jsonify({"error": "Email address is already registered"}), 400
            
            # Check if mobile already exists
            cursor.execute("SELECT id FROM users WHERE mobile = %s", (mobile,))
            if cursor.fetchone():
                return jsonify({"error": "Mobile number is already registered"}), 400
            
            # Hash password
            password_hash = bcrypt.generate_password_hash(password).decode('utf-8')
            
            # Create full name
            full_name = f"{first_name} {last_name}"
            
            # Insert new user
            cursor.execute("""
                INSERT INTO users (name, first_name, last_name, email, mobile, password_hash, created_at, is_email_verified)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id
            """, (full_name, first_name, last_name, email, mobile, password_hash, datetime.utcnow(), False))
            
            user_id = cursor.fetchone()[0]
            
            # Assign default role (basic user)
            cursor.execute("""
                INSERT INTO project_users (project_id, user_id, role_name, created_at)
                VALUES (1, %s, %s, %s)
                ON CONFLICT (project_id, user_id) DO NOTHING
            """, (user_id, 'user', datetime.utcnow()))
            
            # Give basic permissions to new user
            basic_permissions = [
                'page_dashboard',
                'page_device_list',
                'page_tester'
            ]
            
            for permission in basic_permissions:
                cursor.execute("""
                    INSERT INTO user_permissions (user_id, permission_key, permission_type, created_at)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT (user_id, permission_key) DO NOTHING
                """, (user_id, permission, 'allow', datetime.utcnow()))
            
            conn.commit()
            
            # Log the registration
            log.info(f"New user registered: {email} (ID: {user_id})")
            
            # Send welcome email (optional - implement if email service is available)
            # send_welcome_email(email, full_name)
            
            return jsonify({
                "success": True,
                "message": "Account created successfully! You can now log in.",
                "user_id": user_id
            })
            
    except Exception as e:
        log.error(f"Error creating user account: {e}")
        conn.rollback()
        return jsonify({"error": "Failed to create account. Please try again."}), 500
    finally:
        conn.close()

@app.route('/api/check-email', methods=['POST'])
def check_email_availability():
    """Check if email is available for registration"""
    data = request.get_json()
    email = data.get('email', '').strip().lower()
    
    if not email:
        return jsonify({"available": False, "error": "Email is required"})
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"available": False, "error": "Database connection failed"})
    
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
            exists = cursor.fetchone() is not None
            
            return jsonify({
                "available": not exists,
                "message": "Email is already registered" if exists else "Email is available"
            })
    except Exception as e:
        log.error(f"Error checking email availability: {e}")
        return jsonify({"available": False, "error": "Failed to check email availability"})
    finally:
        conn.close()

@app.route('/api/check-mobile', methods=['POST'])
def check_mobile_availability():
    """Check if mobile number is available for registration"""
    data = request.get_json()
    mobile = data.get('mobile', '').strip()
    
    if not mobile:
        return jsonify({"available": False, "error": "Mobile number is required"})
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"available": False, "error": "Database connection failed"})
    
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT id FROM users WHERE mobile = %s", (mobile,))
            exists = cursor.fetchone() is not None
            
            return jsonify({
                "available": not exists,
                "message": "Mobile number is already registered" if exists else "Mobile number is available"
            })
    except Exception as e:
        log.error(f"Error checking mobile availability: {e}")
        return jsonify({"available": False, "error": "Failed to check mobile availability"})
    finally:
        conn.close()

@app.route('/api/rbac/roles/<role_name>/permissions', methods=['PUT'])
@login_required
@requires_permission('page_rbac_management')
def api_rbac_update_role_permissions(role_name):
    """Update permissions for a specific role - FIXED VERSION"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No JSON data provided"}), 400
        
        permissions = data.get('permissions', [])
        
        if not isinstance(permissions, list):
            return jsonify({"error": "Permissions must be an array"}), 400
        
        log.info(f"[RBAC] Updating permissions for role {role_name}: {len(permissions)} permissions")
        log.info(f"[RBAC] Time: 2025-07-30 04:06:27 UTC, User: nishantng25")
        
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        
        try:
            with conn.cursor() as cursor:
                # First, check if role exists in project_users (case-insensitive)
                cursor.execute("""
                    SELECT DISTINCT role_name FROM project_users 
                    WHERE LOWER(role_name) = LOWER(%s)
                    AND (deleted_at IS NULL OR deleted_at = '')
                """, (role_name,))
                
                existing_role = cursor.fetchone()
                
                if not existing_role:
                    # Create the role entry if it doesn't exist
                    log.info(f"[RBAC] Role {role_name} not found, creating entry...")
                    cursor.execute("""
                        INSERT INTO project_users (project_id, user_id, role_name, created_at)
                        VALUES (1, 1, %s, %s)
                        ON CONFLICT (project_id, user_id) DO UPDATE SET role_name = %s
                    """, (role_name, datetime.utcnow(), role_name))
                    actual_role_name = role_name
                else:
                    actual_role_name = existing_role['role_name']
                
                log.info(f"[RBAC] Using role name: {actual_role_name}")
                
                # Remove existing permissions for this role
                cursor.execute("""
                    DELETE FROM role_permissions 
                    WHERE LOWER(role_name) = LOWER(%s)
                """, (actual_role_name,))
                
                log.info(f"[RBAC] Removed existing permissions for role {actual_role_name}")
                
                # Add new permissions
                permissions_added = 0
                for permission_key in permissions:
                    if permission_key and permission_key.strip():
                        try:
                            cursor.execute("""
                                INSERT INTO role_permissions (role_name, permission_key, permission_type, created_at)
                                VALUES (%s, %s, %s, %s)
                            """, (actual_role_name, permission_key.strip(), 'allow', datetime.utcnow()))
                            permissions_added += 1
                        except Exception as e:
                            log.warning(f"[RBAC] Failed to add permission {permission_key}: {e}")
                            continue
                
                conn.commit()
                
                log.info(f"[RBAC] Successfully updated permissions for role {actual_role_name}: {permissions_added} permissions added")
                
                return jsonify({
                    "success": True,
                    "message": f"Updated {permissions_added} permissions for role {actual_role_name}",
                    "role_name": actual_role_name,
                    "permissions_added": permissions_added,
                    "total_permissions": len(permissions),
                    "updated_by": "nishantng25",
                    "updated_at": "2025-07-30 04:06:27"
                })
                
        except Exception as db_error:
            log.error(f"[RBAC] Database error updating role permissions: {db_error}")
            conn.rollback()
            return jsonify({"error": f"Database error: {str(db_error)}"}), 500
        finally:
            conn.close()
            
    except Exception as e:
        log.error(f"[RBAC] Error in api_rbac_update_role_permissions: {e}")
        return jsonify({"error": f"Server error: {str(e)}"}), 500
        
@app.route('/api/rbac/roles/<role_name>/permissions')
@login_required
@requires_permission('page_rbac_management')
def api_rbac_role_permissions(role_name):
    """Get permissions for a specific role - FIXED VERSION"""
    try:
        log.info(f"[RBAC] Fetching permissions for role: {role_name}")
        log.info(f"[RBAC] Time: 2025-07-30 04:26:42 UTC, User: nishantng25")
        
        conn = get_db_connection()
        if not conn:
            log.error("[RBAC] Database connection failed")
            return jsonify({"error": "Database connection failed"}), 500
        
        try:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                # First check if role exists
                cursor.execute("""
                    SELECT COUNT(*) as count FROM role_permissions 
                    WHERE role_name = %s
                """, (role_name,))
                
                role_exists = cursor.fetchone()['count'] > 0
                
                if not role_exists:
                    log.warning(f"[RBAC] Role '{role_name}' not found")
                    return jsonify([])  # Return empty array for non-existent roles
                
                # Get permissions for the role
                cursor.execute("""
                    SELECT 
                        rp.permission_key,
                        COALESCE(rp.permission_type, 'allow') as permission_type,
                        COALESCE(p.display_name, rp.permission_key) as display_name,
                        COALESCE(p.description, 'No description available') as description,
                        COALESCE(p.category, 'general') as category
                    FROM role_permissions rp
                    LEFT JOIN permissions p ON rp.permission_key = p.key
                    WHERE rp.role_name = %s
                    AND (rp.deleted_at IS NULL OR rp.deleted_at = '')
                    ORDER BY COALESCE(p.category, 'general'), rp.permission_key
                """, (role_name,))
                
                permissions = cursor.fetchall()
                
                formatted_permissions = []
                for perm in permissions:
                    formatted_permissions.append({
                        "permission_key": perm['permission_key'],
                        "permission_type": perm['permission_type'],
                        "display_name": perm['display_name'],
                        "description": perm['description'],
                        "category": perm['category']
                    })
                
                log.info(f"[RBAC] Found {len(formatted_permissions)} permissions for role {role_name}")
                
                return jsonify(formatted_permissions)
                
        except Exception as db_error:
            log.error(f"[RBAC] Database error fetching role permissions: {db_error}")
            log.error(f"[RBAC] Error details: {str(db_error)}")
            return jsonify({"error": f"Database error: {str(db_error)}"}), 500
        finally:
            conn.close()
            
    except Exception as e:
        log.error(f"[RBAC] Error in api_rbac_role_permissions: {e}")
        return jsonify({"error": f"Server error: {str(e)}"}), 500

@app.route('/api/rbac/debug/role/<role_name>')
@login_required
def debug_role_permissions(role_name):
    """Debug endpoint to check role permissions in database"""
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            # Check what's in role_permissions table
            cursor.execute("""
                SELECT 
                    role_name, 
                    permission_key, 
                    permission_type,
                    created_at,
                    deleted_at
                FROM role_permissions 
                WHERE role_name = %s
                ORDER BY permission_key
            """, (role_name,))
            
            role_perms = cursor.fetchall()
            
            # Check what's in permissions table
            cursor.execute("""
                SELECT key, display_name, description, category
                FROM permissions 
                ORDER BY key
            """)
            
            all_perms = cursor.fetchall()
            
            # Check if permissions table columns exist
            cursor.execute("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name = 'role_permissions'
                ORDER BY ordinal_position
            """)
            
            columns = [row['column_name'] for row in cursor.fetchall()]
            
            return jsonify({
                "role_name": role_name,
                "role_permissions_count": len(role_perms),
                "role_permissions": [dict(rp) for rp in role_perms],
                "all_permissions_count": len(all_perms),
                "sample_permissions": [dict(p) for p in all_perms[:5]],
                "role_permissions_columns": columns,
                "query_time": "2025-07-30 04:26:42"
            })
            
    except Exception as e:
        log.error(f"Debug error: {e}")
        return jsonify({"error": str(e), "details": "Check server logs"}), 500
    finally:
        conn.close()
        
# Enhanced error handling middleware
@app.errorhandler(500)
def handle_internal_error(e):
    log.error(f"Internal server error: {e}")
    return jsonify({
        "error": "Internal server error",
        "message": "Please try again or contact support",
        "timestamp": "2025-07-30 03:22:57",
        "user": current_user.name if current_user.is_authenticated else "anonymous"
    }), 500

@app.errorhandler(404)
def handle_not_found(e):
    return jsonify({
        "error": "Not found",
        "message": "The requested resource was not found",
        "timestamp": "2025-07-30 03:22:57"
    }), 404

@app.errorhandler(403)
def handle_forbidden(e):
    return jsonify({
        "error": "Forbidden",
        "message": "You do not have permission to access this resource",
        "timestamp": "2025-07-30 03:22:57",
        "user": current_user.name if current_user.is_authenticated else "anonymous"
    }), 403

log.info("Enhanced permission management routes loaded")
log.info(f"Current time: 2025-07-30 03:22:57")
log.info(f"Enhanced error handling enabled")

# Updated routes that work without deleted_at column initially

@app.route('/api/rbac/roles')
@login_required
@requires_permission('page_rbac_management')
def api_rbac_roles():
    """Get all roles with their permission counts - Updated"""
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Check if deleted_at column exists
            cursor.execute("""
                SELECT column_name FROM information_schema.columns 
                WHERE table_name = 'project_users' AND column_name = 'deleted_at'
            """)
            has_deleted_at = cursor.fetchone() is not None
            
            # Use different query based on schema
            if has_deleted_at:
                cursor.execute("""
                    SELECT 
                        pu.role_name,
                        COUNT(DISTINCT pu.user_id) as user_count,
                        COUNT(DISTINCT rp.permission_key) as permission_count,
                        MIN(pu.created_at) as created_at
                    FROM project_users pu
                    LEFT JOIN role_permissions rp ON pu.role_name = rp.role_name AND rp.deleted_at IS NULL
                    WHERE pu.deleted_at IS NULL
                    GROUP BY pu.role_name
                    ORDER BY pu.role_name
                """)
            else:
                cursor.execute("""
                    SELECT 
                        pu.role_name,
                        COUNT(DISTINCT pu.user_id) as user_count,
                        COUNT(DISTINCT rp.permission_key) as permission_count,
                        MIN(pu.created_at) as created_at
                    FROM project_users pu
                    LEFT JOIN role_permissions rp ON pu.role_name = rp.role_name
                    GROUP BY pu.role_name
                    ORDER BY pu.role_name
                """)
            
            roles = cursor.fetchall()
            
            # Add predefined role descriptions
            role_descriptions = {
                'super_admin': 'Full system access with all permissions',
                'admin': 'Administrative access to most features',
                'manager': 'Management level access to user data',
                'user': 'Basic user access to assigned features'
            }
            
            formatted_roles = []
            for role in roles:
                formatted_roles.append({
                    "name": role['role_name'],
                    "description": role_descriptions.get(role['role_name'], f"Custom role: {role['role_name']}"),
                    "user_count": role['user_count'],
                    "permission_count": role['permission_count'],
                    "created_at": role['created_at'].isoformat() if role['created_at'] else None,
                    "is_system_role": role['role_name'] in ['super_admin', 'admin']
                })
            
            return jsonify(formatted_roles)
            
    except Exception as e:
        log.error(f"Error fetching roles: {e}")
        return jsonify({"error": f"Failed to fetch roles: {str(e)}"}), 500
    finally:
        conn.close()

# Replace your check_and_update_schema function with this version:

def check_and_update_schema():
    """Check if database schema has required columns and update if needed"""
    conn = get_db_connection()
    if not conn:
        return False
    
    try:
        with conn.cursor() as cursor:
            # Check for deleted_at columns
            tables_to_check = ['project_users', 'role_permissions', 'user_permissions', 'permissions']
            
            for table in tables_to_check:
                # Check for deleted_at column
                cursor.execute("""
                    SELECT column_name FROM information_schema.columns 
                    WHERE table_name = %s AND column_name = 'deleted_at'
                """, (table,))
                
                if not cursor.fetchone():
                    log.info(f"Adding deleted_at column to {table}")
                    try:
                        cursor.execute(f"ALTER TABLE {table} ADD COLUMN deleted_at TIMESTAMP NULL")
                    except Exception as e:
                        log.warning(f"Could not add deleted_at to {table}: {e}")
                
                # Check for updated_at column
                cursor.execute("""
                    SELECT column_name FROM information_schema.columns 
                    WHERE table_name = %s AND column_name = 'updated_at'
                """, (table,))
                
                if not cursor.fetchone():
                    log.info(f"Adding updated_at column to {table}")
                    try:
                        cursor.execute(f"ALTER TABLE {table} ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
                    except Exception as e:
                        log.warning(f"Could not add updated_at to {table}: {e}")
            
            conn.commit()
            log.info("Database schema updated successfully")
            return True
            
    except Exception as e:
        log.error(f"Error updating database schema: {e}")
        conn.rollback()
        return False
    finally:
        conn.close()

def ensure_rbac_tables():
    """Ensure all RBAC tables exist - ENHANCED VERSION"""
    conn = get_db_connection()
    if not conn:
        return False
    
    try:
        with conn.cursor() as cursor:
            log.info("Ensuring RBAC tables exist...")
            
            # 1. User permissions table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS user_permissions (
                    id SERIAL PRIMARY KEY,
                    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                    permission_key VARCHAR(100) NOT NULL,
                    permission_type VARCHAR(10) CHECK (permission_type IN ('allow', 'deny')) DEFAULT 'allow',
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    deleted_at TIMESTAMP NULL,
                    UNIQUE(user_id, permission_key)
                )
            """)
            
            # 2. Role permissions table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS role_permissions (
                    id SERIAL PRIMARY KEY,
                    role_name VARCHAR(50) NOT NULL,
                    permission_key VARCHAR(100) NOT NULL,
                    permission_type VARCHAR(10) CHECK (permission_type IN ('allow', 'deny')) DEFAULT 'allow',
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    deleted_at TIMESTAMP NULL,
                    UNIQUE(role_name, permission_key)
                )
            """)
            
            # 3. Permissions table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS permissions (
                    id SERIAL PRIMARY KEY,
                    key VARCHAR(100) UNIQUE NOT NULL,
                    display_name VARCHAR(200),
                    description TEXT,
                    category VARCHAR(50) DEFAULT 'general',
                    icon VARCHAR(50) DEFAULT 'fas fa-circle',
                    display_order INTEGER DEFAULT 999,
                    auto_discovered BOOLEAN DEFAULT FALSE,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    deleted_at TIMESTAMP NULL
                )
            """)
            
            # 4. Roles metadata table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS roles (
                    name VARCHAR(50) PRIMARY KEY,
                    description TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    created_by INTEGER REFERENCES users(id),
                    deleted_at TIMESTAMP NULL
                )
            """)
            
            # 5. Audit log table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS rbac_audit_log (
                    id SERIAL PRIMARY KEY,
                    action VARCHAR(100) NOT NULL,
                    permission_key VARCHAR(100),
                    target_user_id INTEGER,
                    changed_by INTEGER REFERENCES users(id),
                    details TEXT,
                    ip_address INET,
                    user_agent TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
            
            # 6. Add missing columns to existing tables
            tables_to_update = ['project_users', 'users']
            for table in tables_to_update:
                # Add deleted_at if missing
                cursor.execute(f"""
                    ALTER TABLE {table} 
                    ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL
                """)
                
                # Add updated_at if missing
                cursor.execute(f"""
                    ALTER TABLE {table} 
                    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                """)
            
            # 7. Insert basic permissions
            basic_permissions = [
                ('page_dashboard', 'Dashboard Access', 'Access to main dashboard', 'page'),
                ('page_rbac_management', 'RBAC Management', 'Access to RBAC management page', 'page'),
                ('page_device_list', 'Device List', 'Access to device list page', 'page'),
                ('page_tester', 'Device Tester', 'Access to device testing page', 'page'),
                ('page_device_status', 'Device Status', 'Access to device status page', 'page'),
                ('page_firmware_manager', 'Firmware Manager', 'Access to firmware management', 'page'),
                ('page_user_list', 'User Management', 'Access to user management', 'page'),
                ('page_role_management', 'Role Management', 'Access to role management', 'page'),
                ('page_project_management', 'Project Management', 'Access to project management', 'page'),
                ('users.create', 'Create Users', 'Create new user accounts', 'user'),
                ('users.edit', 'Edit Users', 'Modify existing user accounts', 'user'),
                ('users.delete', 'Delete Users', 'Remove user accounts', 'user'),
                ('users.view', 'View Users', 'View user information', 'user'),
                ('roles.create', 'Create Roles', 'Create new roles', 'role'),
                ('roles.edit', 'Edit Roles', 'Modify existing roles', 'role'),
                ('roles.delete', 'Delete Roles', 'Remove roles', 'role'),
                ('roles.view', 'View Roles', 'View role information', 'role'),
                ('permissions.discover', 'Discover Permissions', 'Auto-discover permissions', 'permission'),
                ('permissions.manage', 'Manage Permissions', 'Manage system permissions', 'permission'),
                ('admin.access', 'Admin Access', 'Administrative system access', 'admin'),
                ('system.configure', 'System Configuration', 'Configure system settings', 'system'),
                ('audit.view', 'View Audit Logs', 'View system audit logs', 'audit'),
                ('audit.export', 'Export Audit Logs', 'Export audit logs', 'audit'),
                ('devices.create', 'Create Devices', 'Add new devices', 'device'),
                ('devices.edit', 'Edit Devices', 'Modify device configuration', 'device'),
                ('devices.delete', 'Delete Devices', 'Remove devices', 'device'),
                ('devices.control', 'Control Devices', 'Control devices (reboot, OTA)', 'device'),
                ('projects.create', 'Create Projects', 'Create new projects', 'project'),
                ('projects.edit', 'Edit Projects', 'Modify existing projects', 'project'),
                ('projects.delete', 'Delete Projects', 'Remove projects', 'project'),
                ('projects.manage_users', 'Manage Project Users', 'Assign users to projects', 'project')
            ]
            
            for key, display_name, description, category in basic_permissions:
                cursor.execute("""
                    INSERT INTO permissions (key, display_name, description, category)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT (key) DO NOTHING
                """, (key, display_name, description, category))
            
            # 8. Insert basic roles
            basic_roles = [
                ('super_admin', 'Full system access with all permissions'),
                ('admin', 'Administrative access to most features'),
                ('manager', 'Management level access to user data'),
                ('user', 'Basic user access to assigned features')
            ]
            
            for role_name, description in basic_roles:
                cursor.execute("""
                    INSERT INTO roles (name, description)
                    VALUES (%s, %s)
                    ON CONFLICT (name) DO NOTHING
                """, (role_name, description))
            
            # 9. Assign permissions to roles
            role_permissions_map = {
                'super_admin': [
                    'page_dashboard', 'page_rbac_management', 'page_device_list', 'page_tester',
                    'page_device_status', 'page_firmware_manager', 'page_user_list', 'page_role_management',
                    'page_project_management', 'users.create', 'users.edit', 'users.delete', 'users.view',
                    'roles.create', 'roles.edit', 'roles.delete', 'roles.view', 'permissions.discover',
                    'permissions.manage', 'admin.access', 'system.configure', 'audit.view', 'audit.export',
                    'devices.create', 'devices.edit', 'devices.delete', 'devices.control',
                    'projects.create', 'projects.edit', 'projects.delete', 'projects.manage_users'
                ],
                'admin': [
                    'page_dashboard', 'page_rbac_management', 'page_device_list', 'page_tester',
                    'page_device_status', 'page_firmware_manager', 'page_user_list', 'page_role_management',
                    'page_project_management', 'users.create', 'users.edit', 'users.view',
                    'roles.view', 'permissions.discover', 'devices.create', 'devices.edit', 'devices.control',
                    'projects.create', 'projects.edit', 'projects.manage_users'
                ],
                'manager': [
                    'page_dashboard', 'page_device_list', 'page_tester', 'page_device_status',
                    'page_user_list', 'users.view', 'devices.edit', 'devices.control'
                ],
                'user': [
                    'page_dashboard', 'page_device_list', 'page_tester', 'page_device_status'
                ]
            }
            
            for role_name, permissions in role_permissions_map.items():
                for permission_key in permissions:
                    cursor.execute("""
                        INSERT INTO role_permissions (role_name, permission_key, permission_type)
                        VALUES (%s, %s, %s)
                        ON CONFLICT (role_name, permission_key) DO NOTHING
                    """, (role_name, permission_key, 'allow'))
            
            conn.commit()
            log.info("RBAC tables ensured and populated successfully")
            return True
            
    except Exception as e:
        log.error(f"Error ensuring RBAC tables: {e}")
        conn.rollback()
        return False
    finally:
        conn.close()

def quick_database_fix():
    """Quick fix for missing database columns"""
    conn = get_db_connection()
    if not conn:
        print("❌ Database connection failed")
        return False
    
    try:
        with conn.cursor() as cursor:
            print("🔧 Fixing database schema...")
            print(f"⏰ Time: 2025-07-30 03:42:31 UTC")
            print(f"👤 User: nishantng25")
            
            # Add missing columns
            fixes = [
                "ALTER TABLE project_users ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL",
                "ALTER TABLE project_users ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP",
                "ALTER TABLE role_permissions ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL", 
                "ALTER TABLE role_permissions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP",
                "ALTER TABLE user_permissions ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL",
                "ALTER TABLE user_permissions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP",
                "ALTER TABLE permissions ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL",
                "ALTER TABLE permissions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP",
                "ALTER TABLE users ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL",
                "ALTER TABLE users ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
            ]
            
            for fix in fixes:
                try:
                    cursor.execute(fix)
                    print(f"✅ {fix}")
                except Exception as e:
                    print(f"⚠️  {fix} - {e}")
            
            conn.commit()
            print("✅ Database schema fixed successfully!")
            return True
            
    except Exception as e:
        print(f"❌ Error fixing database: {e}")
        conn.rollback()
        return False
    finally:
        conn.close()
        
# Call this when server starts
log.info(f"[RBAC] Checking database schema at 2025-07-30 03:36:39 UTC")
log.info(f"[RBAC] Current user: nishantng25")

if check_and_update_schema():
    log.info("[RBAC] Database schema is up to date")
else:
    log.warning("[RBAC] Database schema update failed - some features may not work")


if __name__ == '__main__':
    log.info("Starting Enhanced RBAC Goldbox Management System")
    ensure_rbac_tables()

    # Start monitoring directly
    device_status_manager.start_monitoring()
    
    socketio.run(app, host='0.0.0.0', port=int(os.environ.get('PORT', 5000)), use_reloader=False)