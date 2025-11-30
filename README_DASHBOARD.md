# E-Commerce MySQL Database Dashboard

A complete Streamlit-based database management dashboard for the E-Commerce MySQL database with full CRUD operations and interactive visualizations.

## 🚀 Quick Start

### 1. Configure MySQL Connection
Edit `app.py` (lines 20-25) and set your credentials:
```python
MYSQL_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',           # Your MySQL username
    'password': 'yourpass',   # Your MySQL password
    'database': 'ecommerce_db'
}
```

### 2. Launch Dashboard
**Windows:** Double-click `run_dashboard.bat`

**Manual:**
```bash
pip install -r requirements.txt
streamlit run app.py
```

### 3. Access Dashboard
Opens automatically at: http://localhost:8501

## 📋 Features

### CRUD Operations
- ✅ **Create** new records with auto-validation
- ✅ **Read** all records with filtering
- ✅ **Update** existing records
- ✅ **Delete** records with confirmation

### Visualizations
- 📊 Customer analytics and demographics
- 📈 Sales trends and product performance
- 💳 Payment and order status tracking
- 📦 Inventory and stock management

## 📁 Project Structure

```
new_database_project/
├── app.py                          # Main Streamlit dashboard (MySQL)
├── requirements.txt                # Python dependencies
├── run_dashboard.bat              # Windows launcher
├── SETUP_INSTRUCTIONS.md          # Detailed setup guide
│
├── security/                      # Security implementation
│   ├── userAccountCreation.sql    # User roles
│   ├── GrantPrivilages.sql        # Permissions
│   ├── ViewAccessControl.sql      # Security views
│   ├── AuditTrailTables.sql       # Audit logging
│   ├── Trigers.sql                # Auto-audit triggers
│   ├── DataMaskingView.sql        # Data masking
│   └── SecurityLog.sql            # Security monitoring
│
├── UserRoleTests/                 # Role testing scripts
│   ├── adminRoleTest.sql
│   ├── salesManagerRoleTest.sql
│   ├── customerServiceRoleTest.sql
│   ├── warehouseStaffRoleTest.sql
│   ├── marketingTeamRoleTest.sql
│   └── deliveryCoordinatorRoleTest.sql
│
├── normal_Schema_MySQL.sql        # Database schema
├── normal_insert.sql              # Sample data
└── Database_Security_Implementation_Report.md
```

## 🔧 Requirements

- **Python 3.8+**
- **MySQL Server 8.0+**
- **Dependencies:** streamlit, pandas, plotly, sqlalchemy, pymysql

## 📖 Documentation

- **Setup Guide:** [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md)
- **Security Report:** [Database_Security_Implementation_Report.md](Database_Security_Implementation_Report.md)
- **Features:** [FEATURES.md](FEATURES.md)

## 🔐 Security Features

- Role-Based Access Control (RBAC)
- View-based data access restrictions
- Automated audit trails with triggers
- Data masking for sensitive information
- Parameterized queries (SQL injection prevention)

## ⚠️ Important Notes

1. **Update MySQL credentials** in `app.py` before running
2. **Create database** using `normal_Schema_MySQL.sql`
3. **Insert sample data** using `normal_insert.sql`
4. **Never commit passwords** to version control

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| Can't connect to MySQL | Verify MySQL is running and credentials are correct |
| No tables found | Run schema creation script first |
| Module not found | Install requirements: `pip install -r requirements.txt` |
| Permission denied | Check MySQL user privileges on `ecommerce_db` |

See [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md) for detailed troubleshooting.

## 🎯 Usage

1. **CRUD Mode:** Manage database records with create, read, update, delete
2. **Visualization Mode:** Analyze data with interactive charts

### Example: Adding a Customer
1. Select CRUD Operations → customer table
2. Choose "Create"
3. Fill in customer details
4. Click "Create Record"

### Example: Viewing Sales Analytics
1. Select Visualizations
2. Choose "Product Sales Analysis"
3. View top-selling products with interactive charts

## 📊 Supported Tables

All tables in ecommerce_db including:
- `customer`, `product`, `orders`, `payment`
- `category`, `rating`, `discount`, `cart`
- `delivery`, `supplier`, `returnTable`
- And more...

## 🔄 Recent Changes

- ✅ Migrated from SQLite to MySQL
- ✅ Removed all SQLite dependencies
- ✅ Updated CHECK constraint detection for MySQL
- ✅ Fixed auto-increment ID handling
- ✅ Updated visualizations for MySQL syntax

---

**Ready to start?** Run `run_dashboard.bat` or see [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md)
