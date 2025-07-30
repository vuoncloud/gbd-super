import eventlet # Move this to the top
eventlet.monkey_patch() # Now this will work correctly

import os
import json
import re
import uuid
from datetime import datetime, timedelta
import psycopg2
from psycopg2.extras import RealDictCursor
import paho.mqtt.client as mqtt
from dotenv import load_dotenv
from flask import Flask, jsonify, request, render_template, send_from_directory, make_response, redirect, url_for, flash
from flask_socketio import SocketIO
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from flask_bcrypt import Bcrypt
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, SelectField
from wtforms.validators import DataRequired, Email, EqualTo, Length, ValidationError, Regexp
from functools import wraps
from flask_mail import Mail, Message
from itsdangerous import URLSafeTimedSerializer
import time

eventlet.monkey_patch()
# --- Load Environment Variables ---
load_dotenv()

# --- Initialize Flask and Extensions ---
app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'a_very_secret_key_that_should_be_changed')
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(hours=12)
socketio = SocketIO(app, async_mode='eventlet')
bcrypt = Bcrypt(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'
login_manager.login_message_category = 'info'

# --- Mail Configuration ---
app.config['MAIL_SERVER'] = os.environ.get('MAIL_SERVER')
app.config['MAIL_PORT'] = int(os.environ.get('MAIL_PORT', 587))
app.config['MAIL_USE_TLS'] = os.environ.get('MAIL_USE_TLS', 'true').lower() in ['true', '1', 't']
app.config['MAIL_USE_SSL'] = os.environ.get('MAIL_USE_SSL', 'false').lower() in ['true', '1', 't']
app.config['MAIL_USERNAME'] = os.environ.get('MAIL_USERNAME')
app.config['MAIL_PASSWORD'] = os.environ.get('MAIL_PASSWORD')
app.config['MAIL_DEFAULT_SENDER'] = os.environ.get('MAIL_USERNAME')
mail = Mail(app)

# --- Global MQTT Client ---
mqtt_client = None
mqtt_reconnect_attempts = 0
MAX_MQTT_RECONNECT_ATTEMPTS = 5

# --- Configuration Constants ---
HTTP_PORT = int(os.environ.get('HTTP_PORT', 5000))
DATABASE_URL = os.environ.get('DATABASE_URL')
YOUR_SERVER_IP = os.environ.get('SERVER_IP', "127.0.0.1")
MQTT_BROKER = os.environ.get('MQTT_BROKER', 'itlmqtt.itlems.com')
MQTT_PORT = int(os.environ.get('MQTT_PORT', 1883))
MQTT_USERNAME = os.environ.get('MQTT_USERNAME')
MQTT_PASSWORD = os.environ.get('MQTT_PASSWORD')
MQTT_HANDSHAKE_TOPIC = 'goldbox-v2/b1/+/config/handshake'
MQTT_LOG_TOPIC = 'goldbox-v2/b1/+/log'
MQTT_VERSION_TOPIC = 'gb-v2/b1/+/+/esv_version'
MQTT_RESPONSE_TOPIC = 'goldbox-v2/b1/+/2/status/response'
FIRMWARE_DIR = '/root/gbd-multi/firmware'
ALLOWED_FIRMWARE_EXTENSIONS = {'.bin'}
MQTT_ALARM_SETTINGS_RESPONSE_TOPIC = 'goldbox-v2/b1/+/1/settings' 

# =================================================================
# USER AUTHENTICATION AND DATABASE MODEL
# =================================================================

class User(UserMixin):
    def __init__(self, id, email, role):
        self.id = id
        self.email = email
        self.role = role
        self._permissions = None
        self._permissions_timestamp = 0

    @property
    def permissions(self):
        now = time.time()
        if self._permissions is None or now - self._permissions_timestamp > 300:  # 5 minute cache
            self._permissions = None
            conn = get_db_connection()
            if not conn:
                self._permissions = []
                return self._permissions
            try:
                with conn.cursor() as cursor:
                    cursor.execute("SELECT page_name FROM user_permissions WHERE user_id = %s", (self.id,))
                    self._permissions = [row[0] for row in cursor.fetchall()]
                    self._permissions_timestamp = now
            except Exception as e:
                print(f"[AUTH] Error fetching permissions for user {self.id}: {e}")
                self._permissions = []
            finally:
                if conn: conn.close()
        return self._permissions

    def has_permission(self, page_name):
        if self.role == 'admin':
            return True
        return page_name in self.permissions

    def get_reset_token(self, expires_sec=1800):
        s = URLSafeTimedSerializer(app.config['SECRET_KEY'])
        return s.dumps({'user_id': self.id})

    @staticmethod
    def verify_reset_token(token):
        s = URLSafeTimedSerializer(app.config['SECRET_KEY'])
        try:
            user_id = s.loads(token, max_age=1800)['user_id']
        except:
            return None
        return load_user(user_id)

@login_manager.user_loader
def load_user(user_id):
    conn = get_db_connection()
    if not conn: return None
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT id, email, role FROM users WHERE id = %s", (int(user_id),))
            user_data = cursor.fetchone()
            if user_data:
                return User(id=user_data['id'], email=user_data['email'], role=user_data['role'])
    except Exception as e:
        print(f"[AUTH] Error loading user: {e}")
    finally:
        if conn: conn.close()
    return None

def permission_required(page_name):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not current_user.has_permission(page_name):
                flash('You do not have permission to access this page.', 'danger')
                return redirect(url_for('dashboard'))
            return f(*args, **kwargs)
        return decorated_function
    return decorator

# --- Forms ---
class RegistrationForm(FlaskForm):
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[
        DataRequired(),
        Length(min=8, message='Password must be at least 8 characters'),
        Regexp(r'(?=.*\d)(?=.*[a-z])(?=.*[A-Z])',
               message='Password must contain at least one uppercase letter, one lowercase letter, and one number')
    ])
    confirm_password = PasswordField('Confirm Password', validators=[DataRequired(), EqualTo('password')])
    role = SelectField('Role', choices=[('viewer', 'Viewer'), ('admin', 'Admin')], validators=[DataRequired()])
    submit = SubmitField('Register')
    def validate_email(self, email):
        conn = get_db_connection()
        if not conn: raise ValidationError('Database connection failed.')
        try:
            with conn.cursor() as cursor:
                cursor.execute("SELECT email FROM users WHERE email = %s", (email.data,))
                if cursor.fetchone():
                    raise ValidationError('That email is already registered.')
        finally:
            if conn: conn.close()

class LoginForm(FlaskForm):
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
    submit = SubmitField('Login')

class RequestResetForm(FlaskForm):
    email = StringField('Email', validators=[DataRequired(), Email()])
    submit = SubmitField('Request Password Reset')

    def validate_email(self, email):
        conn = get_db_connection()
        if not conn: raise ValidationError('Database connection failed.')
        try:
            with conn.cursor() as cursor:
                cursor.execute("SELECT email FROM users WHERE email = %s", (email.data,))
                if cursor.fetchone() is None:
                    raise ValidationError('There is no account with that email. You must register first.')
        finally:
            if conn: conn.close()

class ResetPasswordForm(FlaskForm):
    password = PasswordField('Password', validators=[
        DataRequired(),
        Length(min=8, message='Password must be at least 8 characters'),
        Regexp(r'(?=.*\d)(?=.*[a-z])(?=.*[A-Z])',
               message='Password must contain at least one uppercase letter, one lowercase letter, and one number')
    ])
    confirm_password = PasswordField('Confirm Password', validators=[DataRequired(), EqualTo('password')])
    submit = SubmitField('Reset Password')

# =================================================================
# DATABASE AND HELPERS
# =================================================================
def get_db_connection():
    if not DATABASE_URL:
        print("[DB] ERROR: DATABASE_URL environment variable not set.")
        return None
    try:
        return psycopg2.connect(DATABASE_URL)
    except Exception as e:
        print(f"[DB] Error connecting to database: {e}")
        return None

def get_default_device_config():
    return { "target": {}, "current": {} }

def no_cache_response(rendered_template):
    response = make_response(rendered_template)
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
    return response

def send_reset_email(user):
    token = user.get_reset_token()
    reset_url = url_for('reset_token', token=token, _external=True)
    msg = Message('Password Reset Request',
                sender=app.config['MAIL_DEFAULT_SENDER'],
                recipients=[user.email])
    msg.body = f'''To reset your password, visit the following link:
{reset_url}

If you did not make this request then simply ignore this email and no changes will be made.
The link is valid for 30 minutes.
'''
    try:
        mail.send(msg)
        return True
    except Exception as e:
        print(f"[MAIL] Error sending email: {e}")
        return False

def is_safe_firmware_filename(filename):
    if not filename:
        return False
    if any(part in ('.', '..') for part in filename.split('/')):
        return False
    return os.path.splitext(filename)[1].lower() in ALLOWED_FIRMWARE_EXTENSIONS

# =================================================================
# AUTHENTICATION ROUTES
# =================================================================
@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('dashboard'))
    form = LoginForm()
    if form.validate_on_submit():
        conn = get_db_connection()
        if not conn:
            flash('Login failed due to a server error.', 'danger')
            return redirect(url_for('login'))
        try:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                cursor.execute("SELECT * FROM users WHERE email = %s", (form.email.data,))
                user_data = cursor.fetchone()
                if user_data and bcrypt.check_password_hash(user_data['password_hash'], form.password.data):
                    user = User(id=user_data['id'], email=user_data['email'], role=user_data['role'])
                    login_user(user)
                    next_page = request.args.get('next')
                    flash('Login successful!', 'success')
                    return redirect(next_page) if next_page else redirect(url_for('dashboard'))
                else:
                    flash('Login Unsuccessful. Please check email and password', 'danger')
        except Exception as e:
            print(f"[AUTH] Login error: {e}")
            flash('An error occurred during login.', 'danger')
        finally:
            if conn: conn.close()
    return no_cache_response(render_template('login.html', form=form, title="Login"))

@app.route('/logout')
def logout():
    logout_user()
    return redirect(url_for('login'))

@app.route('/register', methods=['GET', 'POST'])
@login_required
@permission_required('admin_only')
def register():
    form = RegistrationForm()
    if form.validate_on_submit():
        hashed_password = bcrypt.generate_password_hash(form.password.data).decode('utf-8')
        conn = get_db_connection()
        if not conn:
            flash('Registration failed due to a server error.', 'danger')
            return redirect(url_for('register'))
        try:
            with conn.cursor() as cursor:
                cursor.execute("INSERT INTO users (email, password_hash, role) VALUES (%s, %s, %s)",
                               (form.email.data, hashed_password, form.role.data))
                conn.commit()
            flash(f'Account created for {form.email.data}! You can now log in.', 'success')
            return redirect(url_for('user_management_page'))
        except Exception as e:
            print(f"[AUTH] Registration error: {e}")
            flash('An error occurred during registration.', 'danger')
        finally:
            if conn: conn.close()
    return no_cache_response(render_template('register.html', form=form, title="Register"))

@app.route("/reset_password", methods=['GET', 'POST'])
def reset_request():
    if current_user.is_authenticated:
        return redirect(url_for('dashboard'))
    form = RequestResetForm()
    if form.validate_on_submit():
        conn = get_db_connection()
        try:
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                cursor.execute("SELECT * FROM users WHERE email = %s", (form.email.data,))
                user_data = cursor.fetchone()
                if user_data:
                    user = User(id=user_data['id'], email=user_data['email'], role=user_data['role'])
                    if send_reset_email(user):
                        flash('An email has been sent with instructions to reset your password.', 'info')
                    else:
                        flash('There was an error sending the email. Please try again later.', 'danger')
                return redirect(url_for('login'))
        except Exception as e:
             print(f"[AUTH] Password reset request error: {e}")
             flash('An error occurred. Please try again.', 'danger')
        finally:
            if conn: conn.close()
    return no_cache_response(render_template('reset_request.html', title='Reset Password', form=form))

@app.route("/reset_password/<token>", methods=['GET', 'POST'])
def reset_token(token):
    if current_user.is_authenticated:
        return redirect(url_for('dashboard'))
    user = User.verify_reset_token(token)
    if user is None:
        flash('That is an invalid or expired token', 'warning')
        return redirect(url_for('reset_request'))
    form = ResetPasswordForm()
    if form.validate_on_submit():
        hashed_password = bcrypt.generate_password_hash(form.password.data).decode('utf-8')
        conn = get_db_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute("UPDATE users SET password_hash = %s WHERE id = %s", (hashed_password, user.id))
                conn.commit()
            flash('Your password has been updated! You are now able to log in', 'success')
            return redirect(url_for('login'))
        except Exception as e:
            print(f"[AUTH] Password update error: {e}")
            flash('An error occurred while updating your password.', 'danger')
        finally:
            if conn: conn.close()
    return no_cache_response(render_template('reset_token.html', title='Reset Password', form=form))

# =================================================================
# PROTECTED PAGE SERVING ROUTES
# =================================================================
@app.route('/')
@login_required
def dashboard():
    return no_cache_response(render_template('dashboard.html'))

@app.route('/device-list')
@login_required
def device_list_page():
    return no_cache_response(render_template('device_list.html'))

@app.route('/details')
@login_required
def details_page():
    return no_cache_response(render_template('details.html'))

@app.route('/user-management')
@login_required
@permission_required('admin_only')
def user_management_page():
    return no_cache_response(render_template('user_management.html'))

@app.route('/firmware-manager')
@login_required
@permission_required('firmware_manager')
def firmware_manager_page():
    return no_cache_response(render_template('firmware.html'))

@app.route('/device-status')
@login_required
@permission_required('device_status')
def device_status_page():
    return no_cache_response(render_template('device_status.html'))

@app.route('/tester')
@login_required
@permission_required('tester_page')
def tester_page():
    return no_cache_response(render_template('tester.html'))

@app.route('/ems_tester')
@login_required
@permission_required('tester_page')
def ems_tester_page():
    return no_cache_response(render_template('EMS_tester.html'))

# =================================================================
# DEVICE-FACING ROUTES (No login required)
# =================================================================
@app.route('/firmware/<path:filename>')
def download_firmware(filename):
    if not is_safe_firmware_filename(filename):
        return "Invalid filename", 400
    try:
        return send_from_directory(FIRMWARE_DIR, filename, as_attachment=True)
    except FileNotFoundError:
        return "File not found", 404

@app.route('/api/device/<string:group_id>', methods=['GET'])
def device_check_in(group_id):
    mac_address = request.args.get('mac')
    if not mac_address:
        return jsonify({"error": "MAC address is required"}), 400

    fw_version = request.args.get('version', 'unknown')
    build_date = request.args.get('build', 'unknown')
    project = request.args.get('project', 'default')
    device_type = request.args.get('type', 'unknown')
    
    conn = get_db_connection()
    if not conn: return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            # Find or create the device record
            cursor.execute("SELECT * FROM devices WHERE mac_address = %s", (mac_address,))
            device = cursor.fetchone()

            if not device:
                print(f'[HTTP] New device: MAC {mac_address}, Group {group_id}, Type {device_type}. Registering.')
                default_config = get_default_device_config()
                cursor.execute("""
                    INSERT INTO devices (mac_address, device_id, current_fw_version, build_date, last_seen, config, force_config_update, project, is_enabled, device_type)
                    VALUES (%s, %s, %s, %s, NOW(), %s, TRUE, %s, TRUE, %s);
                """, (mac_address, group_id, fw_version, build_date, json.dumps(default_config), project, device_type))
                conn.commit()
            else:
                cursor.execute("""
                    UPDATE devices SET 
                        current_fw_version = %s, build_date = %s, last_seen = NOW(),
                        device_id = %s, project = %s, device_type = %s
                    WHERE mac_address = %s
                """, (fw_version, build_date, group_id, project, device_type, mac_address))
                conn.commit()
                
                if not device.get('is_enabled', True):
                    print(f"[HTTP] Denied check-in for disabled device: {mac_address}")
                    return jsonify({"error": "Device is administratively locked"}), 423
            
            # Refetch the device data after potential update/insert
            cursor.execute("SELECT * FROM devices WHERE mac_address = %s", (mac_address,))
            device = cursor.fetchone()

            response_payload = {'config': {'changeSetting': False}, 'ota_update': {'update_available': False}}

            # Handle forced configuration update
            if device and device.get('force_config_update'):
                print(f"[HTTP] Device {mac_address} has force_config_update=true. Sending target config.")
                response_payload['config'] = {'changeSetting': True, **device['config']['target']}
                #response_payload['config'] = {'changeSetting': True, **device['config']['target']}
                
                #cursor.execute("UPDATE devices SET force_config_update = FALSE WHERE mac_address = %s", (mac_address,))
                #conn.commit()

            # =========================================================================
            # == NEW OTA LOGIC STARTS HERE                                           ==
            # =========================================================================
            update_info = None  # Will hold update details if one is found

            # --- Tier 1: Check for a manually forced update for this specific device ---
            # This allows you to override the automatic update for a single device.
            forced_target_version = device.get('target_fw_version')
            if forced_target_version and forced_target_version != fw_version:
                print(f"[OTA] Device {mac_address} has a forced target version: {forced_target_version}")
                # Check if this forced version exists in the manifest for this specific device_type
                cursor.execute("SELECT path FROM firmware_manifest WHERE version = %s AND device_type = %s", (forced_target_version, device_type))
                firmware = cursor.fetchone()
                if firmware:
                    firmware_url = f"http://{YOUR_SERVER_IP}:{HTTP_PORT}{firmware['path']}"
                    update_info = {'new_version': forced_target_version, 'firmware_url': firmware_url}
                else:
                    print(f"[OTA] WARNING: Forced version {forced_target_version} not found for type '{device_type}'.")

            # --- Tier 2: If no forced update, check for the latest version for the device's type ---
            # This is the automatic update check.
            if not update_info:
                print(f"[OTA] No forced update. Checking for latest version for type '{device_type}'.")
                # This query robustly sorts semantic version strings (e.g., "1.10.0" > "1.2.0") in PostgreSQL
                cursor.execute("""
                    SELECT version, path FROM firmware_manifest 
                    WHERE device_type = %s 
                    ORDER BY string_to_array(version, '.')::int[] DESC 
                    LIMIT 1
                """, (device_type,))
                latest_firmware = cursor.fetchone()
                
                if latest_firmware:
                    latest_version = latest_firmware['version']
                    print(f"[OTA] Latest version for type '{device_type}' is {latest_version}. Device has {fw_version}.")
                    if latest_version != fw_version:
                        firmware_url = f"http://{YOUR_SERVER_IP}:{HTTP_PORT}{latest_firmware['path']}"
                        update_info = {'new_version': latest_version, 'firmware_url': firmware_url}

            # --- Final Step: Populate the response if an update was found ---
            if update_info:
                print(f"[OTA] Offering update to {mac_address}. New version: {update_info['new_version']}")
                response_payload['ota_update'] = {'update_available': True, **update_info}
            # =========================================================================
            # == NEW OTA LOGIC ENDS HERE                                             ==
            # =========================================================================
            
            return jsonify(response_payload)
            
    except Exception as e:
        print(f"Database Error: {e}")
        return jsonify({"error": "Internal server error"}), 500
    finally:
        if conn: conn.close()

@app.route('/api/device/operation_status', methods=['POST'])
def operation_status_update():
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400

    mac_address = data.get('mac')
    operation = data.get('operation')
    status = data.get('status')

    if not mac_address or not operation or not status:
        return jsonify({"error": "Missing mac, operation, or status"}), 400

    print(f"[HTTP-CONFIRM] Received '{operation}' status '{status}' from MAC: {mac_address}")

    # If the device confirms a successful configuration update, we can now safely clear the flag.
    if operation == 'config' and status == 'success':
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        try:
            with conn.cursor() as cursor:
                print(f"[HTTP-CONFIRM] Clearing force_config_update flag for {mac_address}.")
                cursor.execute("UPDATE devices SET force_config_update = FALSE WHERE mac_address = %s", (mac_address,))
                conn.commit()
            return jsonify({"message": "Acknowledged and flag cleared."})
        except Exception as e:
            print(f"[HTTP-CONFIRM] DB Error: {e}")
            return jsonify({"error": "Internal server error"}), 500
        finally:
            if conn: conn.close()
    
    # You can add logic here to handle 'ota' success confirmations if needed in the future.

    return jsonify({"message": "Status received."})



# =================================================================
# PROTECTED API ROUTES
# =================================================================
@app.route('/api/device_types', methods=['GET'])
@login_required
def get_device_types():
    """
    Retrieves a unique list of all device_types from the devices table.
    """
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            # Select the distinct, non-null device_type values
            cursor.execute(
                "SELECT DISTINCT device_type FROM devices WHERE device_type IS NOT NULL ORDER BY device_type"
            )
            # We want a simple list of strings, not a list of objects
            device_types = [row[0] for row in cursor.fetchall()]
            return jsonify(device_types)
    except Exception as e:
        print(f"Error in get_device_types endpoint: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if conn:
            conn.close()

# Add this new function to your Python backend file

@app.route('/api/device_ids', methods=['GET'])
@login_required
def get_device_ids():
    """
    Retrieves a unique list of all device_ids from the devices table.
    """
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "SELECT DISTINCT device_id FROM devices WHERE device_id IS NOT NULL ORDER BY device_id"
            )
            device_ids = [row[0] for row in cursor.fetchall()]
            return jsonify(device_ids)
    except Exception as e:
        print(f"Error in get_device_ids endpoint: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if conn:
            conn.close()
# Add this new function to your Python file

@app.route('/api/firmware/update_type', methods=['POST'])
@login_required
@permission_required('firmware_manager')
def update_firmware_device_type():
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400
        
    version = data.get('version')
    device_type = data.get('device_type')

    if not version or not device_type:
        return jsonify({"error": "Version and device_type are required"}), 400
        
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "UPDATE firmware_manifest SET device_type = %s WHERE version = %s",
                (device_type, version)
            )
            if cursor.rowcount == 0:
                return jsonify({"error": "Firmware version not found"}), 404
            conn.commit()
        return jsonify({"message": "Device type updated successfully."})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if conn:
            conn.close()
            
@app.route('/api/device_types_for_id/<string:device_id>', methods=['GET'])
@login_required
def get_device_types_for_id(device_id):
    """
    Retrieves a unique list of device_types associated with a specific device_id.
    """
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "SELECT DISTINCT device_type FROM devices "
                "WHERE device_id = %s AND device_type IS NOT NULL ORDER BY device_type",
                (device_id,)
            )
            device_types = [row[0] for row in cursor.fetchall()]
            return jsonify(device_types)
    except Exception as e:
        print(f"Error in get_device_types_for_id endpoint: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if conn:
            conn.close()
            
            
@app.route('/api/send_command', methods=['POST'])
@login_required
@permission_required('tester_page')
def send_command():
    if not mqtt_client or not mqtt_client.is_connected():
        return jsonify({"error": "MQTT client not connected"}), 503

    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400

    target_string = data.get('targets')
    command_payload = data.get('payload')
    device_type = data.get('device_type') 

    if not target_string or not command_payload or not device_type:
        return jsonify({"error": "Missing targets, payload, or device_type"}), 400

    if not isinstance(command_payload, (dict, list)):
        return jsonify({"error": "Payload must be a dictionary or array"}), 400

    try:
        correlation_id = f"server-cmd-{uuid.uuid4()}"
        
        final_payload_to_device = {
            "commands": command_payload if isinstance(command_payload, list) else [command_payload]
        }

        for cmd in final_payload_to_device["commands"]:
            cmd['correlation_id'] = correlation_id
        
        device_ids = parse_device_targets(target_string)
        payload_str = json.dumps(final_payload_to_device)
        
        sent_logs = []
        for device_id in device_ids:
            # This is the key change: add device_type to the topic string
            topic = f'goldbox-v2/b1/{device_id}/{device_type}/2/status'
            try:
                mqtt_client.publish(topic, payload_str, qos=1)
                sent_logs.append(f"Command sent to {device_id} (Type: {device_type})...")
            except Exception as e:
                sent_logs.append(f"ERROR publishing to {device_id}: {e}")
        
        return jsonify({
            "correlation_id": correlation_id,
            "logs": sent_logs,
            "device_count": len(device_ids)
        })

    except ValueError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        return jsonify({"error": f"An unexpected error occurred: {e}"}), 500

def parse_device_targets(target_string):
    device_ids = set()
    parts = [p.strip() for p in target_string.replace(' ', '').split(',') if p.strip()]
    
    for part in parts:
        if '-' in part:
            try:
                start_str, end_str = part.split('-')
                if not start_str or not end_str:
                    raise ValueError(f"Invalid range format: {part}")
                
                prefix_match = re.match(r'^([A-Za-z_]+)', start_str)
                if not prefix_match:
                    raise ValueError(f"Invalid prefix in range start: {start_str}")
                prefix_start = prefix_match.group(1)
                
                prefix_match = re.match(r'^([A-Za-z_]+)', end_str)
                if not prefix_match:
                    raise ValueError(f"Invalid prefix in range end: {end_str}")
                prefix_end = prefix_match.group(1)
                
                if prefix_start != prefix_end:
                    raise ValueError(f"Mismatched prefixes in range: {part}")

                num_match = re.search(r'\d+$', start_str)
                if not num_match:
                    raise ValueError(f"Invalid number in range start: {start_str}")
                num_start = int(num_match.group(0))
                
                num_match = re.search(r'\d+$', end_str)
                if not num_match:
                    raise ValueError(f"Invalid number in range end: {end_str}")
                num_end = int(num_match.group(0))
                
                if num_start > num_end:
                    raise ValueError(f"Start of range cannot be greater than end: {part}")

                padding = len(num_match.group(0))

                for i in range(num_start, num_end + 1):
                    device_ids.add(f"{prefix_start}{str(i).zfill(padding)}")

            except (ValueError, AttributeError) as e:
                raise ValueError(f"Invalid range format '{part}': {e}")
        
        else:
            if not part:
                continue
            if not re.match(r'^[A-Za-z][A-Za-z0-9_-]*\d$', part):
                raise ValueError(f"Invalid device ID format: {part}")
            device_ids.add(part)
            
    return sorted(list(device_ids))

@app.route('/api/dashboard/summary')
@login_required
def get_dashboard_summary():
    conn = get_db_connection()
    if not conn: return jsonify({"error": "Database connection failed"}), 500
    summary = { "total_devices": 0, "live_today": 0, "down_sites": 0, "project_distribution": [] }
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("""
                SELECT 
                    COUNT(*) AS total,
                    COUNT(*) FILTER (WHERE last_seen >= NOW() - INTERVAL '24 hours') AS live
                FROM devices;
            """)
            
            counts = cursor.fetchone()
            if counts:
                summary["total_devices"] = counts['total']
                summary["live_today"] = counts['live']
                summary["down_sites"] = counts['total'] - counts['live']

            cursor.execute("""
                SELECT COALESCE(project, 'Unassigned') as project, COUNT(*) as count 
                FROM devices 
                GROUP BY project 
                ORDER BY count DESC;
            """)
            summary["project_distribution"] = cursor.fetchall()
            
            return jsonify(summary)
    except Exception as e:
        print(f"!!! DATABASE ERROR IN SUMMARY ENDPOINT: {e} !!!")
        return jsonify({"error": "An internal database error occurred."}), 500
    finally:
        if conn: conn.close()

@app.route('/api/dashboard/site_status_by_project')
@login_required
def get_site_status_by_project():
    time_range = request.args.get('range', '1-3')
    
    range_map = {
        '1-3': "INTERVAL '3 days'",
        '4-7': "INTERVAL '7 days'",
        '8-10': "INTERVAL '10 days'"
    }
    live_interval = range_map.get(time_range, "INTERVAL '3 days'")

    conn = get_db_connection()
    if not conn: return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            query = f"""
                SELECT 
                    COALESCE(project, 'Unassigned') as project, 
                    COUNT(*) as total,
                    COUNT(*) FILTER (WHERE last_seen >= NOW() - {live_interval}) as live
                FROM devices
                GROUP BY project
                ORDER BY total DESC;
            """
            cursor.execute(query)
            results = cursor.fetchall()
            
            for row in results:
                row['down'] = row['total'] - row['live']
            
            return jsonify(results)
            
    except Exception as e:
        print(f"Error in site status endpoint: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/devices/filtered')
@login_required
def get_filtered_devices():
    status_filter = request.args.get('status')
    project_filter = request.args.get('project')
    conn = get_db_connection()
    if not conn: return jsonify({"error": "Database connection failed"}), 500
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            query = "SELECT mac_address, device_id, current_fw_version, build_date, project, last_seen FROM devices"
            conditions = []
            params = []
            if status_filter == 'live':
                conditions.append("last_seen >= NOW() - INTERVAL '24 hours'")
            elif status_filter == 'down':
                conditions.append("last_seen < NOW() - INTERVAL '24 hours'")
            if project_filter:
                if project_filter == 'Unassigned':
                    conditions.append("project IS NULL")
                else:
                    conditions.append("project = %s")
                    params.append(project_filter)
            if conditions:
                query += " WHERE " + " AND ".join(conditions)
            query += " ORDER BY device_id, mac_address;"
            cursor.execute(query, tuple(params))
            devices = cursor.fetchall()
            return jsonify(devices)
    except Exception as e:
        print(f"Error in filtered devices endpoint: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/devices', methods=['GET'])
@login_required
def get_all_devices():
    conn = get_db_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT * FROM devices ORDER BY device_id, mac_address")
            devices = cursor.fetchall()
            return jsonify(devices)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/users', methods=['GET'])
@login_required
@permission_required('admin_only')
def get_all_users():
    conn = get_db_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT id, email, role FROM users WHERE id != %s ORDER BY email", (current_user.id,))
            users = cursor.fetchall()
            return jsonify(users)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/permissions', methods=['GET', 'POST'])
@login_required
@permission_required('admin_only')
def manage_permissions():
    conn = get_db_connection()
    if not conn: return jsonify({"error": "Database connection failed"}), 500
    try:
        if request.method == 'GET':
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                cursor.execute("SELECT user_id, page_name FROM user_permissions")
                return jsonify(cursor.fetchall())
        
        elif request.method == 'POST':
            data = request.get_json()
            user_id = data.get('user_id')
            page_name = data.get('page_name')
            has_permission = data.get('has_permission')

            if None in [user_id, page_name, has_permission]:
                return jsonify({"error": "Missing required fields"}), 400

            with conn.cursor() as cursor:
                if has_permission:
                    cursor.execute("INSERT INTO user_permissions (user_id, page_name) VALUES (%s, %s) ON CONFLICT DO NOTHING;", (user_id, page_name))
                else:
                    cursor.execute("DELETE FROM user_permissions WHERE user_id = %s AND page_name = %s;", (user_id, page_name))
                conn.commit()
            return jsonify({"message": "Permission updated successfully."})

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/device/<string:mac_address>/config', methods=['POST'])
@login_required
@permission_required('admin_only')
def update_device_config(mac_address):
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400
        
    conn = get_db_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT config, target_fw_version FROM devices WHERE mac_address = %s", (mac_address,))
            device = cursor.fetchone()
            if not device: return jsonify({"error": "Device not found"}), 404
            
            current_config = device['config']
            if 'config' in data:
                for key, value in data['config'].items():
                    current_config['target'][key] = value
            
            target_fw = data.get('target_fw_version', device['target_fw_version'])
            
            cursor.execute("UPDATE devices SET config = %s, target_fw_version = %s, force_config_update = TRUE WHERE mac_address = %s", (json.dumps(current_config), target_fw, mac_address))
            conn.commit()
            return jsonify({"message": "Device configuration updated successfully."})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/device/<string:mac_address>/status', methods=['POST'])
@login_required
@permission_required('device_status')
def set_device_status(mac_address):
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400
        
    is_enabled = data.get('is_enabled')
    if is_enabled is None or not isinstance(is_enabled, bool):
        return jsonify({"error": "is_enabled (boolean) is required"}), 400
        
    conn = get_db_connection()
    if not conn: return jsonify({"error": "Database connection failed"}), 500
    try:
        with conn.cursor() as cursor:
            cursor.execute("UPDATE devices SET is_enabled = %s WHERE mac_address = %s", (is_enabled, mac_address))
            if cursor.rowcount == 0: return jsonify({"error": "Device not found"}), 404
            conn.commit()
        status_text = "enabled" if is_enabled else "disabled"
        return jsonify({"message": f"Device {mac_address} has been {status_text}."})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/firmware', methods=['GET', 'POST'])
@login_required
@permission_required('firmware_manager')
def manage_firmware():
    conn = get_db_connection()
    if not conn: return jsonify({"error": "Database connection failed"}), 500
    try:
        if request.method == 'GET':
            with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                cursor.execute("SELECT * FROM firmware_manifest ORDER BY version DESC")
                return jsonify(cursor.fetchall())
        elif request.method == 'POST':
            data = request.get_json()
            if not data:
                return jsonify({"error": "No data provided"}), 400
                
            version, path = data.get('version'), data.get('path')
            if not version or not path: 
                return jsonify({"error": "Version and path are required"}), 400
            with conn.cursor() as cursor:
                cursor.execute("""
                    INSERT INTO firmware_manifest (version, path) 
                    VALUES (%s, %s) 
                    ON CONFLICT (version) DO UPDATE SET path = EXCLUDED.path;
                """, (version, path))
                conn.commit()
            return jsonify({"message": f"Firmware version {version} added/updated successfully."}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/firmware/<string:version>', methods=['DELETE'])
@login_required
@permission_required('firmware_manager')
def delete_firmware(version):
    conn = get_db_connection()
    if not conn: return jsonify({"error": "Database connection failed"}), 500
    try:
        with conn.cursor() as cursor:
            cursor.execute("DELETE FROM firmware_manifest WHERE version = %s", (version,))
            if cursor.rowcount == 0: return jsonify({"error": "Version not found"}), 404
            conn.commit()
        return jsonify({"message": f"Firmware version {version} deleted successfully."})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if conn: conn.close()

@app.route('/api/alarm_relay/publish_settings', methods=['POST'])
@login_required
# @permission_required('tester_page') # You can uncomment this to protect the endpoint
def publish_alarm_settings():
    if not mqtt_client or not mqtt_client.is_connected():
        return jsonify({"error": "MQTT client not connected"}), 503

    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400

    device_id = data.get('device_id')
    payload = data.get('payload')

    if not device_id or not payload:
        return jsonify({"error": "Missing device_id or payload"}), 400

    try:
        topic = f'goldbox-v2/b1/{device_id}/2/settings'
        payload_str = json.dumps(payload)
        
        mqtt_client.publish(topic, payload_str, qos=1)
        
        return jsonify({
            "message": "Settings published successfully.",
            "topic": topic,
            "payload": payload
        })
    except Exception as e:
        return jsonify({"error": f"An unexpected error occurred: {e}"}), 500


@app.route('/api/alarm_relay/send_command', methods=['POST'])
@login_required
# @permission_required('tester_page') # You can uncomment this to protect the endpoint
def send_alarm_command():
    if not mqtt_client or not mqtt_client.is_connected():
        return jsonify({"error": "MQTT client not connected"}), 503

    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400

    device_id = data.get('device_id')
    payload = data.get('payload')

    if not device_id or not payload:
        return jsonify({"error": "Missing device_id or payload"}), 400

    try:
        topic = f'goldbox-v2/b1/{device_id}/cmd'
        payload_str = json.dumps(payload)
        
        mqtt_client.publish(topic, payload_str, qos=1)
        
        return jsonify({
            "message": "Command sent successfully.",
            "topic": topic,
            "payload": payload
        })
    except Exception as e:
        return jsonify({"error": f"An unexpected error occurred: {e}"}), 500

@app.route('/api/alarm_relay/update_status', methods=['POST'])
@login_required
# @permission_required('tester_page') # You can uncomment this to protect the endpoint
def update_relay_status():
    if not mqtt_client or not mqtt_client.is_connected():
        return jsonify({"error": "MQTT client not connected"}), 503

    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400

    device_id = data.get('device_id')
    payload = data.get('payload')

    if not device_id or not payload:
        return jsonify({"error": "Missing device_id or payload"}), 400

    try:
        # The topic for status updates, as per your instructions
        topic = f'goldbox-v2/b1/{device_id}/2/status'
        payload_str = json.dumps(payload)
        
        mqtt_client.publish(topic, payload_str, qos=1)
        
        return jsonify({
            "message": "Status update published successfully.",
            "topic": topic,
            "payload": payload
        })
    except Exception as e:
        return jsonify({"error": f"An unexpected error occurred: {e}"}), 500




# =================================================================
# MQTT AND WEBSOCKET LOGIC
# =================================================================
def on_connect(client, userdata, flags, rc):
    global mqtt_reconnect_attempts
    if rc == 0:
        print('[MQTT] Connected to broker.')
        mqtt_reconnect_attempts = 0
        client.subscribe(MQTT_HANDSHAKE_TOPIC)
        client.subscribe(MQTT_LOG_TOPIC)
        client.subscribe(MQTT_VERSION_TOPIC)
        client.subscribe(MQTT_RESPONSE_TOPIC)
        client.subscribe(MQTT_ALARM_SETTINGS_RESPONSE_TOPIC)
        print(f'[MQTT] Subscribed to: {MQTT_HANDSHAKE_TOPIC}')
        print(f'[MQTT] Subscribed to: {MQTT_LOG_TOPIC}')
        print(f'[MQTT] Subscribed to: {MQTT_VERSION_TOPIC}')
        print(f'[MQTT] Subscribed to: {MQTT_RESPONSE_TOPIC}')
        print(f'[MQTT] Subscribed to: {MQTT_ALARM_SETTINGS_RESPONSE_TOPIC}')
    else:
        print(f'[MQTT] Connection failed with code {rc}')

def on_disconnect(client, userdata, rc):
    global mqtt_reconnect_attempts
    print(f"[MQTT] Disconnected with code {rc}")
    if rc != 0:
        mqtt_reconnect_attempts += 1
        if mqtt_reconnect_attempts <= MAX_MQTT_RECONNECT_ATTEMPTS:
            print(f"[MQTT] Attempting to reconnect ({mqtt_reconnect_attempts}/{MAX_MQTT_RECONNECT_ATTEMPTS})...")
            time.sleep(min(2 ** mqtt_reconnect_attempts, 30))  # Exponential backoff
            try:
                client.reconnect()
            except Exception as e:
                print(f"[MQTT] Reconnect failed: {e}")
        else:
            print("[MQTT] Max reconnection attempts reached. Giving up.")

def on_message(client, userdata, msg):
    topic = msg.topic
    try:
        payload_str = msg.payload.decode('utf-8', 'ignore')
        
        if '/2/status/response' in topic:
            try:
                print(f"[MQTT-RESPONSE] Received: {payload_str} on {topic}")
                response_data = json.loads(payload_str)
#                socketio.start_background_task(socketio.emit, 'command_response', response_data)
                socketio.server.emit('command_response', response_data)
            except Exception as e:
                print(f"[MQTT-RESPONSE] Error processing response: {e}")
            return
        elif '/1/settings' in topic:
            try:
                print(f"[MQTT-ALARM-RESPONSE] Received: {payload_str} on {topic}")
                response_data = json.loads(payload_str)
                device_id = topic.split('/')[2]
                
                # Emit a specific event for this type of response
                socketio.server.emit('alarm_settings_response', {
                    "device_id": device_id,
                    "payload": response_data
                })
            except Exception as e:
                print(f"[MQTT-ALARM-RESPONSE] Error processing settings response: {e}")
            return

        version_topic_pattern = re.compile(r'gb-v2/b1/([^/]+)/([^/]+)/esv_version')
        match = version_topic_pattern.match(topic)
        
        if match:
            mac_address = match.group(1)
            group_id = match.group(2)
            print(f'[MQTT-CHECKIN] Received version from MAC: {mac_address} | Group: {group_id}')
            
            try:
                payload = json.loads(payload_str)
                fw_version = payload.get('FW_VER')
                if not fw_version:
                    print(f'[MQTT-CHECKIN] ERROR: "FW_VER" missing in payload for {mac_address}.')
                    return

                conn = get_db_connection()
                if not conn:
                    print("[MQTT-CHECKIN] ERROR: Database connection failed.")
                    return
                
                try:
                    with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                        cursor.execute("SELECT mac_address FROM devices WHERE mac_address = %s", (mac_address,))
                        device = cursor.fetchone()

                        if device:
                            print(f'[MQTT-CHECKIN] Updating existing device: {mac_address}')
                            cursor.execute("""
                                UPDATE devices SET current_fw_version = %s, last_seen = NOW(), device_id = %s
                                WHERE mac_address = %s
                            """, (fw_version, group_id, mac_address))
                        else:
                            print(f'[MQTT-CHECKIN] Registering new device: {mac_address}')
                            default_config = get_default_device_config()
                            cursor.execute("""
                                INSERT INTO devices (mac_address, device_id, current_fw_version, last_seen, config, project, is_enabled)
                                VALUES (%s, %s, %s, NOW(), %s, %s, TRUE)
                            """, (mac_address, group_id, fw_version, json.dumps(default_config), 'mqtt_registered'))
                        
                        conn.commit()
                        print(f'[MQTT-CHECKIN] Successfully processed version for {mac_address}')

                except Exception as e:
                    print(f"[MQTT-CHECKIN] DB ERROR for {mac_address}: {e}")
                    if conn: conn.rollback()
                finally:
                    if conn: conn.close()

            except json.JSONDecodeError:
                print(f"[MQTT-CHECKIN] ERROR: Could not decode JSON payload from {topic}: {payload_str}")
            except Exception as e:
                print(f"[MQTT-CHECKIN] UNEXPECTED ERROR for {mac_address}: {e}")
            
            return

        try:
            topic_parts = topic.split('/')
            if len(topic_parts) < 3: return
            device_id = topic_parts[2]
            
            if topic.endswith('/config/handshake'):
                print(f'[MQTT] Handshake from {device_id}: {payload_str}')
                payload = json.loads(payload_str)
                if payload.get('status') == 'applied':
                    print(f'[MQTT] Device {device_id} applied new config. Sending commit command.')
                    commit_topic = f'goldbox-v2/b1/{device_id}/config/handshake'
                    commit_payload = json.dumps({'command': 'commit'})
                    client.publish(commit_topic, commit_payload)
            elif topic.endswith('/log'):
                print(f'[LOG] From {device_id}: {payload_str}')
                socketio.emit('new_log', {'device_id': device_id, 'log': payload_str})
        except Exception as e:
            print(f'[MQTT] Error processing message on topic {topic}: {e}')
    
    except UnicodeDecodeError:
        print(f"[MQTT] Could not decode message payload on topic {topic}")
    except Exception as e:
        print(f"[MQTT] Unexpected error processing message: {e}")

def setup_mqtt():
    global mqtt_client
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION1)
    if MQTT_USERNAME:
        client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)
    client.on_connect = on_connect
    client.on_disconnect = on_disconnect
    client.on_message = on_message
    
    mqtt_client = client

    try:
        client.connect(MQTT_BROKER, MQTT_PORT, 60)
        client.loop_start()
    except Exception as e:
        print(f'[MQTT] Could not connect to broker: {e}')
        # Schedule a reconnection attempt
        threading.Timer(5, setup_mqtt).start()

# =================================================================
# MAIN EXECUTION
# =================================================================
if __name__ == '__main__':
    setup_mqtt()
    print(f"--- Server starting on http://0.0.0.0:{HTTP_PORT} ---")
    socketio.run(app, host='0.0.0.0', port=HTTP_PORT)


