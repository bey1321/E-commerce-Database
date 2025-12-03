# E-Commerce MySQL Database Dashboard v2.0

Streamlit-based database management dashboard with Role-Based Access Control, database views, audit trails, and interactive analytics.

---

## 🚀 Quick Start

### 1. Configure MySQL Connection
Create a `.env` file in the project root:
```bash
# Copy .env.example to .env
cp .env.example .env

# Edit .env with your MySQL credentials
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=your_password
MYSQL_DATABASE=ecommerce_db
```

### 2. Launch Dashboard
**Windows:** Double-click `run_dashboard.bat`

**Manual:**
```bash
pip install -r requirements.txt
streamlit run app.py
```

### 3. Login
Use the credentials configured in `security/userAccountCreation.sql`:
```
Admin: admin_user
Sales: sales_manager
CS: customer_service
Warehouse: warehouse_staff
Marketing: marketing_team
Delivery: delivery_coordinator
```
**Note:** Passwords are set in the SQL file - change them for production use!

Dashboard opens at: **http://localhost:8501**

---

## ✨ Features

### 3 Operation Modes

#### 1. CRUD Operations
- ✅ **Create** - Auto-generated forms with validation
- ✅ **Read** - Interactive data tables
- ✅ **Update** - Pre-filled forms with PK protection
- ✅ **Delete** - Confirmation dialogs

**Admin Extra:** Quick Access panel for audit tables (`customer_audit`, `card_audit`, `product_audit`, `orders_audit`, `payment_audit`, `security_log`)

#### 2. View Data *(NEW)*
- 👁️ Access role-specific database views
- 🔍 Search and filter by any column
- 📊 View numeric statistics
- 📥 Export to CSV with timestamps
- 📋 Available views: `OrderSummaryView`, `CustomerServiceView`, `ReturnManagementView`, `MarketingAnalyticsView`, `ActiveDeliveryView`

#### 3. Visualizations
- 📈 Customer analytics (age, growth, status)
- 📊 Sales trends and product performance
- 💳 Payment and order status tracking
- 📦 Inventory and stock management

---

## 🔐 Role-Based Access

### Role Permissions

| Role | Tables/Views | Operations | Special Access |
|------|-------------|------------|----------------|
| **Admin** | All + audit tables | All (CRUD) | Audit trails, security logs |
| **Sales Manager** | customer, orders, payment, ordersummaryview | Read, Update (orders) | Sales analytics |
| **Customer Service** | customer, orders, returnTable, customerserviceview, returnmanagementview | Read, Update (returns) | Return management |
| **Warehouse Staff** | product, supplier, supplierProduct, productAnalytics | Read, Create, Update | Inventory management |
| **Marketing Team** | marketinganalyticsview, customer, orders, product, discount | Read only | Full analytics access |
| **Delivery Coordinator** | delivery, orders, customer, address, activedeliveryview | Read, Update (delivery) | Active deliveries |

---

## 📊 Available Database Views

### Role-Specific Views

1. **OrderSummaryView** (Sales Manager)
   - Order summaries with customer and payment info
   - Access via: Login as `sales_manager` → View Data mode

2. **CustomerServiceView** (Customer Service)
   - Customer overview with order and return data
   - Access via: Login as `customer_service` → View Data mode

3. **ReturnManagementView** (Customer Service)
   - Return processing and refund tracking
   - **Special:** Can UPDATE this view
   - Access via: Login as `customer_service` → View Data mode

4. **MarketingAnalyticsView** (Marketing Team)
   - Customer insights and campaign analytics
   - Access via: Login as `marketing_team` → View Data mode

5. **ActiveDeliveryView** (Delivery Coordinator)
   - Currently active deliveries with status
   - Access via: Login as `delivery_coordinator` → View Data mode

**Note:** Views are **lowercase** in the dropdown (e.g., `activedeliveryview`)

---

## 🔒 Audit Trails & Security Logs (Admin Only)

### Quick Access Panel

When logged in as `admin_user`, you'll see a **Quick Access** panel with buttons for:

**Audit Trail Tables:**
- 📋 `customer_audit` - Customer record changes
- 📋 `card_audit` - Payment card updates
- 📋 `product_audit` - Product modifications
- 📋 `orders_audit` - Order changes
- 📋 `payment_audit` - Payment modifications

**Security Log:**
- 🔐 `security_log` - Security events and access attempts

### How to Access
1. Login as `admin_user`
2. Select **CRUD Operations** mode
3. Expand **"🔒 Quick Access: Audit & Security Tables"**
4. Click any table button to jump to it
5. Select **Read** operation to view logs

### What's Logged
- **User:** Who made the change
- **Action:** INSERT, UPDATE, DELETE
- **Old/New Values:** Before and after values
- **Timestamp:** When the change occurred

---

## 🎯 Usage Examples

### Example 1: View Customer Orders (Sales Manager)
```
1. Login: sales_manager (with your configured password)
2. Select: View Data mode
3. Choose: ordersummaryview
4. Search: Filter by customer name or order ID
5. Export: Download as CSV if needed
```

### Example 2: Manage Returns (Customer Service)
```
1. Login: customer_service (with your configured password)
2. Select: View Data mode
3. Choose: returnmanagementview
4. Search: Find specific return by ReturnID
5. View: All return details with customer and product info
```

### Example 3: Monitor Active Deliveries (Delivery Coordinator)
```
1. Login: delivery_coordinator (with your configured password)
2. Select: View Data mode
3. Choose: activedeliveryview
4. View: All pending/in-transit deliveries
5. Go to: CRUD Operations → delivery table → Update delivery status
```

### Example 4: Review Audit Logs (Admin)
```
1. Login: admin_user (with your configured password)
2. Select: CRUD Operations mode
3. Expand: Quick Access panel
4. Click: customer_audit button
5. Select: Read operation
6. Filter: Search by ChangedBy to find user's actions
```

---

## 📁 Project Structure

```
new_database_project/
├── app.py (1088 lines)           # Main dashboard with RBAC
├── requirements.txt               # Python dependencies
├── run_dashboard.bat             # Windows launcher
│
├── 📖 Documentation
│   ├── README.md                  # Main documentation
│   ├── README_DASHBOARD.md        # This file
│   ├── VIEW_ACCESS_GUIDE.md       # View data mode guide
│   └── AUDIT_TRAIL_GUIDE.md       # Audit trails guide
│
├── security/                      # Security implementation
│   ├── userAccountCreation.sql    # Create 6 user roles
│   ├── GrantPrivilages.sql        # Grant permissions
│   ├── ViewAccessControl.sql      # Create role-specific views
│   ├── AuditTrailTables.sql       # Create audit tables
│   ├── Trigers.sql                # Auto-audit triggers
│   ├── DataMaskingView.sql        # Sensitive data masking
│   └── SecurityLog.sql            # Security event logging
│
├── normal_Schema_MySQL.sql        # Database schema
└── normal_insert.sql              # Sample data
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| **Can't see views** | Views are lowercase (e.g., `activedeliveryview` not `ActiveDeliveryView`) |
| **No views in dropdown** | Your role may not have view access. Check role permissions. |
| **Audit tables not showing** | Scroll through dropdown to find `*_audit` tables, or use Quick Access buttons (admin only) |
| **Can't update view** | Most views are read-only. Only `returnmanagementview` allows updates for customer service |
| **Connection error** | Check MySQL is running and credentials are correct in `app.py` |
| **No tables found** | Import schema: `mysql -u root -p ecommerce_db < normal_Schema_MySQL.sql` |

---

## 🔧 Requirements

**System:**
- Python 3.8+
- MySQL Server 8.0+

**Python Dependencies:**
```
streamlit>=1.28.0
pandas>=2.0.0
plotly>=5.17.0
sqlalchemy>=2.0.0
pymysql>=1.1.0
cryptography>=41.0.0
```

**Install:** `pip install -r requirements.txt`

---

## 🔄 Recent Changes (v2.0)

### New Features
- ✅ **View Data Mode** - Browse role-specific database views with search/filter/export
- ✅ **Admin Quick Access** - Fast access to audit tables and security logs
- ✅ **View Names Fix** - Properly handle lowercase view names in MySQL
- ✅ **Enhanced RBAC** - Table and view permissions per role

### Improvements
- ✅ Better view filtering (only shows accessible views)
- ✅ Quick Access panel with one-click buttons (admin)
- ✅ CSV export with timestamps
- ✅ Numeric statistics for view data
- ✅ Comprehensive documentation

---

## 📖 Additional Resources

**Guides:**
- [VIEW_ACCESS_GUIDE.md](VIEW_ACCESS_GUIDE.md) - Complete guide to using View Data mode
- [AUDIT_TRAIL_GUIDE.md](AUDIT_TRAIL_GUIDE.md) - Admin guide for audit trails and security logs
- [README.md](README.md) - Main project documentation

**Security:**
- [Database_Security_Implementation_Report.md](Database_Security_Implementation_Report.md) - Full security documentation

---

## 🆘 Support

**Need help?**
1. Check error messages (they include hints!)
2. See troubleshooting section above
3. Review guide files (VIEW_ACCESS_GUIDE.md, AUDIT_TRAIL_GUIDE.md)
4. Check MySQL error logs

---

<div align="center">

**E-Commerce MySQL Database Dashboard v2.0**

Built with Streamlit, SQLAlchemy, and MySQL

**Run:** `run_dashboard.bat` or `streamlit run app.py`

</div>
