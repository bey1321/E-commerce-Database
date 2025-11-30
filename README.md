# 🛒 E-Commerce Database Management Dashboard

> A modern, interactive web dashboard for managing MySQL e-commerce databases with complete CRUD operations and real-time analytics.

![Built with](https://img.shields.io/badge/Built%20with-Streamlit-red) ![Database](https://img.shields.io/badge/Database-MySQL-blue) ![Python](https://img.shields.io/badge/Python-3.8%2B-green)

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [Quick Start](#-quick-start)
- [Setup Guide](#-setup-guide)
- [Usage](#-usage)
- [Troubleshooting](#-troubleshooting)
- [Project Structure](#-project-structure)
- [Security Features](#-security-features)
- [Contributing](#-contributing)

---

## 🌟 Overview

This dashboard provides a complete web-based interface for managing your MySQL e-commerce database. Built with **Streamlit** and **SQLAlchemy**, it offers:

- **Full CRUD Operations** - Create, Read, Update, and Delete records from any table
- **Interactive Visualizations** - Real-time charts and analytics powered by Plotly
- **Smart Forms** - Automatically generated forms with input validation
- **Security** - Role-based access control, audit trails, and SQL injection prevention
- **Zero Configuration** - Auto-detects your database schema and adapts

**Perfect for:** Database administrators, developers, business analysts, and students learning database management.

---

## ✨ Features

### 🔧 CRUD Operations

| Operation | Description |
|-----------|-------------|
| **Create** | Auto-generated forms with smart input types (date pickers, number inputs, dropdowns) |
| **Read** | Interactive data tables with sorting and filtering |
| **Update** | Pre-filled forms with validation and primary key protection |
| **Delete** | Safe deletion with confirmation dialogs |

### 📊 Advanced Visualizations

1. 📈 **Customer Age Distribution** - Demographic analysis with histogram
2. 📅 **Customer Growth Over Time** - Track user acquisition trends
3. 👥 **Customer Account Status** - Active/Inactive/Suspended breakdown
4. 🛒 **Product Sales Analysis** - Top 20 best-selling products
5. 📦 **Product Stock Status** - Real-time inventory monitoring
6. 💰 **Order Amount Distribution** - Revenue analysis over time
7. 🚚 **Order Status Overview** - Track order pipeline
8. 💳 **Payment Status Breakdown** - Payment completion rates

### 🔒 Security Features

- ✅ **SQL Injection Prevention** - All queries use parameterized statements
- ✅ **Password URL Encoding** - Special characters in passwords are properly handled
- ✅ **Role-Based Access Control** - 6 different user roles with specific permissions
- ✅ **Audit Trails** - Automatic logging of all data modifications
- ✅ **Data Masking** - Sensitive information protected in views
- ✅ **Input Validation** - Date formats and CHECK constraints enforced

---

## 🖼️ Screenshots

### Dashboard Interface
```
┌─────────────────────────────────────────────────────────┐
│  🛒 E-Commerce Database Management Dashboard            │
├─────────────────────────────────────────────────────────┤
│  Navigation                │  Main Content Area         │
│  ─────────────            │  ─────────────────         │
│  📊 Connected to:         │  📋 CRUD Operations         │
│      ecommerce_db         │                            │
│                           │  Select Table: [customer ▾]│
│  ⚙️ Select Mode:          │                            │
│   ○ CRUD Operations       │  Operation: [Create ▾]     │
│   ○ Visualizations        │                            │
│                           │  [Interactive Forms Here]   │
│  Select Table:            │                            │
│   [Dropdown ▾]            │                            │
│                           │                            │
│  Operation:               │  [Data/Charts Display]     │
│   ○ Create                │                            │
│   ○ Read                  │                            │
│   ○ Update                │                            │
│   ○ Delete                │                            │
└───────────────────────────┴────────────────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have:

- ✅ **Python 3.8 or higher** installed ([Download Python](https://www.python.org/downloads/))
- ✅ **MySQL Server 8.0+** installed and running ([Download MySQL](https://dev.mysql.com/downloads/))
- ✅ **Git** (optional, for cloning the repository)

### Installation in 3 Steps

#### Step 1: Clone or Download

```bash
git clone <repository-url>
cd new_database_project
```

Or download and extract the ZIP file.

#### Step 2: Configure Database Connection

Open `app.py` and update your MySQL credentials (lines 19-25):

```python
MYSQL_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',              # ← Your MySQL username
    'password': 'your_password',  # ← Your MySQL password
    'database': 'ecommerce_db'    # ← Your database name
}
```

**Important:** If your password contains special characters like `@`, `#`, `!`, etc., don't worry - they are automatically URL-encoded.

#### Step 3: Install and Run

**Option A: Automatic (Windows)**
```bash
# Double-click this file:
run_dashboard.bat
```

**Option B: Manual**
```bash
# Install dependencies
pip install -r requirements.txt

# Run the dashboard
python -m streamlit run app.py
```

The dashboard will automatically open in your browser at `http://localhost:8501` 🎉

---

## 📚 Setup Guide

### Creating the Database

If you haven't created the database yet:

```bash
# 1. Connect to MySQL
mysql -u root -p

# 2. Create database
CREATE DATABASE ecommerce_db;

# 3. Exit MySQL
exit

# 4. Import schema
mysql -u root -p ecommerce_db < normal_Schema_MySQL.sql

# 5. Import sample data (optional)
mysql -u root -p ecommerce_db < normal_insert.sql
```

### Implementing Security Features

To enable role-based access control and audit trails:

```bash
# 1. Create user accounts
mysql -u root -p ecommerce_db < security/userAccountCreation.sql

# 2. Grant privileges
mysql -u root -p ecommerce_db < security/GrantPrivilages.sql

# 3. Create audit tables
mysql -u root -p ecommerce_db < security/AuditTrailTables.sql

# 4. Create triggers
mysql -u root -p ecommerce_db < security/Trigers.sql

# 5. Create security views
mysql -u root -p ecommerce_db < security/ViewAccessControl.sql
mysql -u root -p ecommerce_db < security/DataMaskingView.sql
mysql -u root -p ecommerce_db < security/SecurityLog.sql
```

---

## 🎯 Usage

### CRUD Operations Guide

#### 1️⃣ Creating Records

1. Select **"CRUD Operations"** from the sidebar
2. Choose a table (e.g., `customer`)
3. Select **"Create"** operation
4. Fill in the form:
   - 📅 **Date fields**: Use the date picker
   - 🔢 **Numeric fields**: Use number spinners
   - 📝 **Text fields**: Type directly
   - 🎯 **Constrained fields**: Select from dropdown (e.g., Gender: Male/Female)
5. Click **"Create Record"**

**Note:** Auto-increment IDs are displayed but not editable - they're generated automatically!

#### 2️⃣ Reading Records

1. Select table and **"Read"** operation
2. View all records in an interactive table
3. Scroll horizontally/vertically to explore data
4. See total record count at the bottom

#### 3️⃣ Updating Records

1. Select table and **"Update"** operation
2. Choose a record from the dropdown
3. Modify the pre-filled form (primary keys cannot be changed)
4. Click **"Update Record"**

#### 4️⃣ Deleting Records

1. Select table and **"Delete"** operation
2. View all records first
3. Select the record to delete
4. Review details carefully
5. Click **"Confirm Delete"**

⚠️ **Warning:** Deletion is permanent! Ensure you have backups.

### Visualizations Guide

1. Select **"Visualizations"** from the sidebar
2. Choose a visualization from the dropdown
3. Interact with charts:
   - **Hover** to see detailed values
   - **Zoom** by dragging
   - **Pan** by holding shift and dragging
   - **Download** using the camera icon

All visualizations update in real-time based on your actual database data!

---

## 🐛 Troubleshooting

### Common Issues and Solutions

<details>
<summary><b>❌ "Can't connect to MySQL server"</b></summary>

**Causes:**
- MySQL server is not running
- Incorrect host or port
- Firewall blocking connection

**Solutions:**
1. **Check if MySQL is running:**
   - Windows: Open Services (`Win + R` → `services.msc`), find MySQL service, ensure it's "Running"
   - Mac: `brew services list`
   - Linux: `sudo systemctl status mysql`

2. **Start MySQL if stopped:**
   - Windows: Right-click MySQL service → Start
   - Mac: `brew services start mysql`
   - Linux: `sudo systemctl start mysql`

3. **Verify connection manually:**
   ```bash
   mysql -u root -p
   # If this fails, MySQL is not running or credentials are wrong
   ```
</details>

<details>
<summary><b>❌ "Access denied for user 'root'@'localhost'"</b></summary>

**Solution:**
1. Check your password in `app.py` line 23
2. Ensure special characters are included exactly as they are
3. Try resetting MySQL root password:
   ```bash
   ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
   FLUSH PRIVILEGES;
   ```
</details>

<details>
<summary><b>❌ "Unknown database 'ecommerce_db'"</b></summary>

**Solution:**
The database doesn't exist. Create it:
```bash
mysql -u root -p
CREATE DATABASE ecommerce_db;
exit
```
</details>

<details>
<summary><b>❌ "No tables found in database"</b></summary>

**Solution:**
The database is empty. Import the schema:
```bash
mysql -u root -p ecommerce_db < normal_Schema_MySQL.sql
```
</details>

<details>
<summary><b>❌ Dashboard shows old error after fixing connection</b></summary>

**Solution:**
Streamlit caches the database connection. Clear it:
1. In your browser, press **`C`** while on the dashboard
2. Or click the menu (☰) → "Clear cache"
3. Or restart the dashboard
</details>

<details>
<summary><b>❌ "Foreign key constraint fails" when creating records</b></summary>

**Solution:**
You're trying to create a child record without a parent. For example:
- Creating an order without a customer
- Creating an order product without a product

**Fix:** Create the parent record first (e.g., customer, product) then create the child record.
</details>

<details>
<summary><b>❌ Date validation errors</b></summary>

**Solution:**
- Always use the date picker instead of typing
- If typing, use format: `YYYY-MM-DD` (e.g., `2024-03-15`)
- Ensure dates are valid (e.g., not `2024-02-30`)
</details>

---

## 📁 Project Structure

```
new_database_project/
│
├── 📄 app.py                              # Main dashboard application
├── 📄 requirements.txt                    # Python dependencies
├── 📄 run_dashboard.bat                   # Windows quick launcher
│
├── 📖 README.md                           # This file
├── 📖 SETUP_INSTRUCTIONS.md              # Detailed setup guide
├── 📖 README_DASHBOARD.md                # Dashboard-specific documentation
├── 📖 Database_Security_Implementation_Report.md  # Security documentation
│
├── 📁 security/                          # Security implementation scripts
│   ├── userAccountCreation.sql           # Create role-based user accounts
│   ├── GrantPrivilages.sql               # Assign role permissions
│   ├── ViewAccessControl.sql             # Role-specific views
│   ├── AuditTrailTables.sql              # Audit logging tables
│   ├── Trigers.sql                       # Auto-audit triggers
│   ├── DataMaskingView.sql               # Sensitive data masking
│   └── SecurityLog.sql                   # Security event logging
│
├── 📁 UserRoleTests/                     # Test scripts for each role
│   ├── adminRoleTest.sql                 # Admin privileges test
│   ├── salesManagerRoleTest.sql          # Sales manager test
│   ├── customerServiceRoleTest.sql       # Customer service test
│   ├── warehouseStaffRoleTest.sql        # Warehouse staff test
│   ├── marketingTeamRoleTest.sql         # Marketing team test
│   └── deliveryCoordinatorRoleTest.sql   # Delivery coordinator test
│
├── 📄 normal_Schema_MySQL.sql            # Complete database schema
└── 📄 normal_insert.sql                  # Sample data for testing
```

---

## 🛡️ Security Features

This project implements comprehensive database security following industry best practices:

### Role-Based Access Control (RBAC)

6 distinct user roles with specific permissions:

| Role | Permissions | Use Case |
|------|-------------|----------|
| **Admin** | Full access to all tables and operations | System administration |
| **Sales Manager** | Customer, orders, products, discounts | Sales operations |
| **Customer Service** | Customer info, orders, returns | Customer support |
| **Warehouse Staff** | Products, inventory, suppliers | Inventory management |
| **Marketing Team** | Customer data (read-only), campaigns | Marketing analytics |
| **Delivery Coordinator** | Orders, delivery, addresses | Logistics |

### Audit Trail System

All data modifications are automatically logged:
- **Who** made the change (user)
- **What** was changed (old and new values)
- **When** it was changed (timestamp)
- **Which** record was affected

### Data Masking

Sensitive information is masked in certain views:
- Credit card numbers: `****-****-****-1234`
- Email addresses: `j***@example.com`
- Phone numbers: `***-***-5678`

### Security Event Logging

All security-related events are logged:
- Failed login attempts
- Permission denials
- Suspicious activity patterns

**📖 For detailed security documentation, see:** [Database_Security_Implementation_Report.md](Database_Security_Implementation_Report.md)

---

## 🎨 Customization

### Adding Custom Visualizations

Want to add your own charts? Follow this template:

```python
def viz_your_custom_chart():
    """Your custom visualization"""
    st.subheader("📊 Your Chart Title")

    try:
        engine = get_engine()
        query = text("""
            SELECT column1, COUNT(*) as count
            FROM your_table
            GROUP BY column1
        """)

        with engine.connect() as conn:
            df = pd.read_sql(query, conn)

        if not df.empty:
            fig = px.bar(df, x='column1', y='count',
                        title='Your Chart Title')
            st.plotly_chart(fig, use_container_width=True)
        else:
            st.info("No data available")
    except Exception as e:
        st.error(f"Error: {str(e)}")
```

Then add it to the visualization selector in the `main()` function around line 746.

### Connecting to a Different Database

You can use this dashboard with any MySQL database! Just:

1. Update `MYSQL_CONFIG` in `app.py`:
   ```python
   MYSQL_CONFIG = {
       'host': 'your-host',           # e.g., 'db.example.com'
       'port': 3306,                  # default MySQL port
       'user': 'your-username',
       'password': 'your-password',
       'database': 'your-database'
   }
   ```

2. The dashboard will automatically:
   - Detect all tables
   - Identify primary keys
   - Recognize column types
   - Generate appropriate forms

---

## 📊 Technical Details

### Dependencies

```
streamlit>=1.28.0     # Web dashboard framework
pandas>=2.0.0         # Data manipulation
plotly>=5.17.0        # Interactive visualizations
sqlalchemy>=2.0.0     # Database ORM
pymysql>=1.1.0        # MySQL database driver
cryptography>=41.0.0  # Secure connections
```

### Architecture Highlights

- **Cached Database Connection**: Uses `@st.cache_resource` for performance
- **Connection Pooling**: SQLAlchemy manages connection pool automatically
- **Parameterized Queries**: All SQL uses `:placeholder` format to prevent injection
- **URL-Encoded Passwords**: Special characters in passwords are properly handled
- **Responsive Design**: Wide layout optimized for data-heavy operations

### Browser Compatibility

Tested and working on:
- ✅ Google Chrome (recommended)
- ✅ Mozilla Firefox
- ✅ Microsoft Edge
- ✅ Safari

---

## 📈 Performance Tips

1. **Add Database Indexes**: Index frequently queried columns
   ```sql
   CREATE INDEX idx_customer_email ON customer(Email);
   ```

2. **Limit Large Tables**: For tables with millions of rows, consider adding pagination

3. **Optimize Visualizations**: Use SQL aggregations instead of fetching all data

4. **Monitor Connection Pool**: SQLAlchemy handles this, but watch for connection leaks

---

## 🔄 Updates and Maintenance

### Updating Dependencies

```bash
pip install --upgrade -r requirements.txt
```

### Backing Up Your Database

```bash
# Full backup
mysqldump -u root -p ecommerce_db > backup_$(date +%Y%m%d).sql

# Restore from backup
mysql -u root -p ecommerce_db < backup_20240315.sql
```

### Database Migration

If you update your schema:
1. The dashboard auto-detects changes on restart
2. No code modifications needed!
3. Just restart: `python -m streamlit run app.py`

---

## 🤝 Contributing

Contributions are welcome! Here's how:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 License

This project is created for educational purposes. Feel free to use and modify.

---

## 🆘 Support

Need help? Try these resources:

1. **Error messages**: Most errors include helpful hints
2. **Troubleshooting section**: See above for common issues
3. **Setup guide**: [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md)
4. **Security docs**: [Database_Security_Implementation_Report.md](Database_Security_Implementation_Report.md)

---

## 🎓 Learning Resources

New to databases? Check these out:

- [MySQL Documentation](https://dev.mysql.com/doc/)
- [Streamlit Documentation](https://docs.streamlit.io/)
- [SQLAlchemy Tutorial](https://docs.sqlalchemy.org/en/20/tutorial/)
- [Plotly Documentation](https://plotly.com/python/)

---

## ⭐ Acknowledgments

Built with amazing open-source technologies:
- **Streamlit** for the incredible web framework
- **SQLAlchemy** for powerful ORM capabilities
- **Plotly** for beautiful interactive charts
- **Pandas** for data manipulation
- **PyMySQL** for MySQL connectivity

---

<div align="center">

**🛒 E-Commerce Database Management Dashboard**

Built with ❤️ using Streamlit, SQLAlchemy, and MySQL

[Get Started](#-quick-start) • [Documentation](#-documentation) • [Support](#-support)

---

*Ready to manage your database?* 🚀 **Run `run_dashboard.bat` or `python -m streamlit run app.py`**

</div>
