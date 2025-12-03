# 🛒 E-Commerce Database Management Dashboard

> Modern web dashboard for MySQL e-commerce databases with Role-Based Access Control, CRUD operations, database views, and real-time analytics.

![Built with](https://img.shields.io/badge/Built%20with-Streamlit-red) ![Database](https://img.shields.io/badge/Database-MySQL-blue) ![Python](https://img.shields.io/badge/Python-3.8%2B-green)

---

## 🌟 Overview

Complete web-based interface for managing MySQL e-commerce databases with enterprise-grade security and intuitive operations.

**Key Features:**
- **Role-Based Access Control** - 6 user roles with specific permissions
- **CRUD Operations** - Create, Read, Update, Delete with smart forms
- **Database Views** - Access role-specific views with search and export
- **Audit Trails** - Track all changes with who, what, when
- **Interactive Visualizations** - Real-time charts powered by Plotly
- **Security** - SQL injection prevention, data masking, security logs

**Perfect for:** Database administrators, developers, business analysts, and students.

---

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- MySQL Server 8.0+

### Installation

```bash
# 1. Clone/Download the project
git clone <repository-url>
cd new_database_project

# 2. Configure database connection
# Copy .env.example to .env and update with your credentials
cp .env.example .env
# Edit .env with your MySQL credentials

# 3. Install and run
pip install -r requirements.txt
streamlit run app.py
```

**Windows users:** Double-click `run_dashboard.bat`

Dashboard opens at: `http://localhost:8501` 🎉

---

## ✨ Main Features

### 1. 🔐 Role-Based Access Control

Login with different roles to access role-specific features:

| Role | Username | Access |
|------|----------|--------|
| **Administrator** | `admin_user` | Full access + audit trails + security logs |
| **Sales Manager** | `sales_manager` | Customers, orders, sales view |
| **Customer Service** | `customer_service` | Customer data, returns, service view |
| **Warehouse Staff** | `warehouse_staff` | Products, inventory, suppliers |
| **Marketing Team** | `marketing_team` | Analytics view, customer insights |
| **Delivery Coordinator** | `delivery_coordinator` | Deliveries, active delivery view |

### 2. 📋 CRUD Operations

**Features:**
- Auto-generated smart forms (date pickers, dropdowns, number inputs)
- Primary key protection (auto-increment, read-only)
- CHECK constraint validation
- Foreign key awareness
- Confirmation dialogs for deletions

### 3. 👁️ View Data Mode *(NEW)*

**Access role-specific database views:**
- Browse pre-filtered, pre-joined data
- Search and filter by any column
- View numeric statistics
- Export to CSV with timestamps
- Views include: `OrderSummaryView`, `CustomerServiceView`, `ReturnManagementView`, `MarketingAnalyticsView`, `ActiveDeliveryView`

### 4. 🔒 Audit Trails & Security Logs *(Admin Only)*

**Quick Access Panel for:**
- `customer_audit` - Track customer changes
- `card_audit` - Monitor payment card updates
- `product_audit` - Product modifications
- `orders_audit` - Order changes
- `payment_audit` - Payment modifications
- `security_log` - Security events and access attempts

**Each log captures:** User, action, old/new values, timestamp

### 5. 📊 Visualizations

**8 Interactive Charts:**
- Customer Age Distribution
- Customer Growth Over Time
- Customer Account Status
- Product Sales Analysis
- Product Stock Status
- Order Amount Distribution
- Order Status Overview
- Payment Status Breakdown

**Features:** Hover details, zoom, pan, download

---

## 📚 Setup Guide

### 1. Create Database

```bash
mysql -u root -p
CREATE DATABASE ecommerce_db;
exit

# Import schema
mysql -u root -p ecommerce_db < normal_Schema_MySQL.sql

# Insert sample data (optional)
mysql -u root -p ecommerce_db < normal_insert.sql
```

### 2. Enable Security Features

```bash
# Create user accounts
mysql -u root -p ecommerce_db < security/userAccountCreation.sql

# Grant privileges
mysql -u root -p ecommerce_db < security/GrantPrivilages.sql

# Create audit tables
mysql -u root -p ecommerce_db < security/AuditTrailTables.sql

# Enable triggers
mysql -u root -p ecommerce_db < security/Trigers.sql

# Create views
mysql -u root -p ecommerce_db < security/ViewAccessControl.sql
mysql -u root -p ecommerce_db < security/DataMaskingView.sql
mysql -u root -p ecommerce_db < security/SecurityLog.sql
```

### 3. Login

Use the credentials you set in `security/userAccountCreation.sql`. Default usernames are:

```
Admin: admin_user
Sales: sales_manager
CS: customer_service
Warehouse: warehouse_staff
Marketing: marketing_team
Delivery: delivery_coordinator
```

**Note:** Change the default passwords in `security/userAccountCreation.sql` before running it in production!

---

## 🎯 Usage

### CRUD Operations
1. Select **CRUD Operations** mode
2. Choose table from dropdown (or use Quick Access for audit tables)
3. Select operation: Create, Read, Update, or Delete
4. Complete the form/action

### View Data *(NEW)*
1. Select **View Data** mode
2. Choose a view from dropdown (only shows views you can access)
3. Search/filter data
4. Export to CSV if needed

### Visualizations
1. Select **Visualizations** mode
2. Choose chart from dropdown (based on role permissions)
3. Interact with charts (hover, zoom, download)

---

## 📁 Project Structure

```
new_database_project/
├── app.py                          # Main dashboard (1088 lines)
├── requirements.txt                # Dependencies
├── run_dashboard.bat              # Windows launcher
│
├── 📖 Documentation
│   ├── README.md                  # This file
│   ├── README_DASHBOARD.md        # Dashboard-specific docs
│   ├── VIEW_ACCESS_GUIDE.md       # View data mode guide
│   ├── AUDIT_TRAIL_GUIDE.md       # Audit trails guide
│   └── Database_Security_Implementation_Report.md
│
├── security/                      # Security implementation
│   ├── userAccountCreation.sql    # User roles
│   ├── GrantPrivilages.sql        # Permissions
│   ├── ViewAccessControl.sql      # Role-specific views
│   ├── AuditTrailTables.sql       # Audit tables
│   ├── Trigers.sql                # Auto-audit triggers
│   ├── DataMaskingView.sql        # Sensitive data masking
│   └── SecurityLog.sql            # Security event log
│
├── UserRoleTests/                 # Test scripts
│   └── *RoleTest.sql              # SQL tests for each role
│
├── normal_Schema_MySQL.sql        # Database schema
└── normal_insert.sql              # Sample data
```

---

## 🛡️ Security Features

### SQL Injection Prevention
- All queries use parameterized statements (`:placeholder` format)
- Password URL encoding for special characters
- Input validation on all forms

### Role-Based Access Control (RBAC)
- 6 user roles with specific table/view permissions
- Operations restricted by role (create/read/update/delete)
- Visualizations filtered by role

### Audit Trail System
- Automatic logging of all data modifications
- Captures: User, action (INSERT/UPDATE/DELETE), old/new values, timestamp
- Triggered automatically via MySQL triggers

### Data Masking
- Credit cards: `****-****-****-1234`
- Emails: `j***@example.com`
- Phone: `***-***-5678`

### Security Event Logging
- Failed login attempts
- Permission denials
- Suspicious activity
- Admin-only access

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| **Can't connect to MySQL** | Check MySQL is running: `services.msc` (Windows) |
| **Access denied** | Verify credentials in `.env` file |
| **Unknown database** | Create database: `CREATE DATABASE ecommerce_db;` |
| **No tables found** | Import schema: `mysql ... < normal_Schema_MySQL.sql` |
| **No views for role** | The views are lowercase (e.g., `activedeliveryview`) |
| **Audit tables not visible** | Click dropdown and scroll to find `*_audit` tables |
| **Foreign key constraint** | Create parent record first (e.g., customer before order) |

**Clear cache:** Press `C` in browser or restart dashboard

---

## 📊 Technical Details

### Dependencies
```
streamlit>=1.28.0     # Web framework
pandas>=2.0.0         # Data manipulation
plotly>=5.17.0        # Visualizations
sqlalchemy>=2.0.0     # Database ORM
pymysql>=1.1.0        # MySQL driver
```

### Architecture
- Cached database connections (`@st.cache_resource`)
- SQLAlchemy connection pooling
- Parameterized queries for security
- Auto-schema detection
- Responsive wide layout

---

## 🔄 Recent Updates (v2.0)

- ✅ **View Data Mode** - Access role-specific database views with search/export
- ✅ **Audit Trail Access** - Admin quick access panel for audit tables
- ✅ **Security Logs** - Comprehensive security event tracking
- ✅ **Improved RBAC** - Table and view permissions per role
- ✅ **View Names** - Fixed lowercase view name handling
- ✅ **Documentation** - Added VIEW_ACCESS_GUIDE.md and AUDIT_TRAIL_GUIDE.md

---

## 📖 Additional Documentation

- **View Access Guide:** [VIEW_ACCESS_GUIDE.md](VIEW_ACCESS_GUIDE.md) - How to use View Data mode
- **Audit Trail Guide:** [AUDIT_TRAIL_GUIDE.md](AUDIT_TRAIL_GUIDE.md) - Admin audit trail access
- **Security Report:** [Database_Security_Implementation_Report.md](Database_Security_Implementation_Report.md)
- **Dashboard Details:** [README_DASHBOARD.md](README_DASHBOARD.md)

---

## 🎨 Customization

### Connect to Different Database
Update the `.env` file:
```bash
MYSQL_HOST=your-host
MYSQL_PORT=3306
MYSQL_USER=your-username
MYSQL_PASSWORD=your-password
MYSQL_DATABASE=your-database
```
Dashboard auto-detects tables, columns, and generates forms!

---

## 🆘 Support

**Error messages include hints!** Also check:
1. Troubleshooting section above
2. [VIEW_ACCESS_GUIDE.md](VIEW_ACCESS_GUIDE.md)
3. [AUDIT_TRAIL_GUIDE.md](AUDIT_TRAIL_GUIDE.md)
4. Error logs in MySQL

---

## 📝 License

Created for educational purposes. Free to use and modify.

---

<div align="center">

**🛒 E-Commerce Database Management Dashboard v2.0**

Built with ❤️ using Streamlit, SQLAlchemy, and MySQL

[Quick Start](#-quick-start) • [Features](#-main-features) • [Setup](#-setup-guide) • [Documentation](#-additional-documentation)

---

*Ready to manage your database?* 🚀

**Run:** `run_dashboard.bat` or `streamlit run app.py`

**Login as:** `admin_user` (with password from userAccountCreation.sql)

</div>
