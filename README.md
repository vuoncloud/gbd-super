# RBAC Management System

A comprehensive Role-Based Access Control (RBAC) management system with a web-based interface for managing users, roles, and permissions.

## 🚀 Features

- **User Management**: Create, update, and manage user accounts
- **Role Management**: Define and manage user roles with hierarchical permissions
- **Permission Control**: Granular permission assignment and management
- **Web Interface**: Intuitive dashboard for RBAC administration
- **Database Integration**: PostgreSQL backend with soft delete functionality
- **RESTful API**: Complete API endpoints for all RBAC operations

## 🛠️ Tech Stack

### Backend
- **API Framework**: Flask/Python (based on API endpoint structure)
- **Database**: PostgreSQL
- **Authentication**: JWT-based authentication
- **Port**: 5000 (API server)

### Frontend
- **Framework**: React/JavaScript (based on web interface)
- **UI Components**: Modern responsive design
- **API Integration**: RESTful API consumption

### Database Schema
- `project_users` - User management with role assignments
- `permissions` - Available system permissions
- `role_permissions` - Role-permission mappings
- Soft delete support with `deleted_at` timestamps

## 📋 Prerequisites

- Python 3.8+
- PostgreSQL 12+
- Node.js 14+ (for frontend)
- Git

## 🔧 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/nishantng25/rbac-management-system.git
cd rbac-management-system
