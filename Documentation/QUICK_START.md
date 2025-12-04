# 🚀 Quick Start Guide

## Run the Dashboard (3 Easy Steps)

### Option 1: Using the Batch File (Easiest - Windows)
1. Double-click [run_dashboard.bat](run_dashboard.bat)
2. Wait for dependencies to install
3. Dashboard opens automatically in your browser!

### Option 2: Manual Commands
```bash
# Step 1: Install dependencies
pip install -r requirements.txt

# Step 2: Run the app
python -m streamlit run app.py
```

## 🔐 Login (Role-Based Access Control)

When the dashboard opens, you'll see the **Login Page**. The system uses role-based access control with 6 different user roles.

### Available User Roles & Credentials

| Role | Username | Password | Access Level |
|------|----------|----------|--------------|
| **Administrator** | `admin_user` | `SecurePass123!` | Full access to all tables, operations, and visualizations |
| **Sales Manager** | `sales_manager` | `SalesPass456!` | Customer, orders, products, payments (read & update orders) |
| **Customer Service** | `customer_service` | `CSPass789!` | Customer support, returns, order tracking |
| **Warehouse Staff** | `warehouse_staff` | `WarehousePass012!` | Products, inventory, suppliers |
| **Marketing Team** | `marketing_team` | `MarketPass345!` | Analytics, customer data, all visualizations |
| **Delivery Coordinator** | `delivery_coordinator` | `DeliveryPass678!` | Delivery management, order tracking |

### First Login
1. **Enter your username** (e.g., `admin_user`)
2. **Enter your password** (e.g., `SecurePass123!`)
3. **Click "Login"**
4. You'll see a welcome message with your role

**💡 Tip**: Start with `admin_user` to explore all features, then try other roles to see how permissions work!

## First Time Using the Dashboard?

### Understanding Your Dashboard

After login, you'll see:
- **Your role name** displayed at the top (e.g., "Administrator")
- **Sidebar navigation** with available modes
- **Three main modes**: CRUD Operations, View Data, Visualizations

**Note**: Your available tables and operations depend on your role!

### CRUD Operations Tutorial

1. **Select "CRUD Operations"** mode in the sidebar
2. **Choose a table** from the dropdown (permissions vary by role)
3. **Select available operations** (Create/Read/Update/Delete based on your role)

   **Create a Record:**
   - Select "Create" operation
   - Fill in the form (auto-increment IDs are generated automatically)
   - Click "Create Record"

   **View All Records:**
   - Select "Read" operation
   - Scroll through the data table
   - Check the total record count at the bottom

   **Update a Record:**
   - Select "Update" operation
   - Choose a record from the dropdown
   - Edit the form fields (Primary keys are protected)
   - Click "Update Record"

   **Delete a Record:**
   - Select "Delete" operation
   - Choose a record to delete
   - Review the record details
   - Click "Confirm Delete" (⚠️ Cannot be undone!)

**🔒 Admin Feature**: Administrators have quick access buttons for audit tables (customer_audit, payment_audit, security_log, etc.) in the sidebar!

### View Data Mode (Database Views)

1. **Select "View Data"** mode in the sidebar
2. **Choose a database view** (pre-configured read-only reports)
   - `ordersummaryview` - Order summaries with customer info
   - `customerserviceview` - Customer service overview
   - `marketinganalyticsview` - Marketing insights
   - `activedeliveryview` - Active deliveries
3. **Use search and filter** to find specific records
4. **Download as CSV** for offline analysis

### Visualizations Tutorial

1. **Select "Visualizations"** mode in the sidebar
2. **Choose from available charts** (varies by role):
   - Customer Age Distribution
   - Customer Growth Over Time
   - Product Sales Analysis
   - Product Stock Status
   - Order Amount Distribution
   - Order Status Overview
   - Payment Status Breakdown
   - Customer Account Status

**Note**: Marketing Team has access to ALL visualizations!

## 💡 Pro Tips

- **Role Permissions**: Your username determines what you can access (admin has full access)
- **Logout & Switch Roles**: Use the "Logout" button in sidebar to switch between users
- **Date Format**: Always use yyyy-mm-dd (e.g., 2024-03-15)
- **Use Date Picker**: Click the calendar icon instead of typing dates
- **Primary Keys**: They're auto-detected and protected from editing
- **Interactive Charts**: Hover, zoom, and click on visualizations
- **Safe Operations**: All queries use parameterized statements (SQL injection prevention)
- **Audit Trail**: Admin users can view all database changes in audit tables
- **Quick Access**: Admins get special quick-access buttons for audit/security tables

## 🎯 What Tables Should I Start With? (By Role)

### 👑 Administrator (`admin_user`)
Start with these to understand the system:
- `customer` - Core user data
- `orders` - Transaction records
- `customer_audit` - See who changed what
- `security_log` - Track login attempts

### 📊 Sales Manager (`sales_manager`)
Focus on these tables:
- `customer` (Read only)
- `orders` (Read & Update)
- `product` (Read only)
- `payment` (Read only)

### 🎧 Customer Service (`customer_service`)
Work with these:
- `customer` (Read only)
- `orders` (Read only)
- `returnTable` (Read only)
- `returnmanagementview` (Update returns)

### 📦 Warehouse Staff (`warehouse_staff`)
Manage inventory:
- `product` (Read & Update)
- `supplierProduct` (Full CRUD)
- `supplier` (Read only)
- `productAnalytics` (Read only)

### 📈 Marketing Team (`marketing_team`)
Analyze data:
- All views (read-only analytics)
- `customer`, `orders`, `product` (Read only)
- Access to ALL visualizations!

### 🚚 Delivery Coordinator (`delivery_coordinator`)
Track deliveries:
- `delivery` (Read & Update)
- `orders` (Read only)
- `activedeliveryview` (Current deliveries)
- `customer`, `address` (Read only)

## ⚠️ Important Notes

1. **Authentication**: You must log in with valid credentials. The system connects to MySQL using your role-based credentials for security.

2. **Role Permissions**: Each role has specific permissions. If you try to access a table or operation not allowed for your role, you'll see an access denied message.

3. **Foreign Keys**: When creating records in tables with foreign keys (like `orders`), make sure the referenced records exist first (e.g., create customer before creating their order)

4. **Primary Keys**:
   - Auto-increment PKs are handled automatically
   - Manual PKs need to be unique
   - Composite PKs require all parts

5. **Dates**:
   - Format: yyyy-mm-dd
   - Example: 2024-03-15
   - Use the date picker for accuracy

6. **Database Connection**: The app uses environment variables from `.env` file for MySQL connection. Ensure your `.env` file is properly configured.

7. **Audit Logging**: All database operations are logged (visible to admin users only)

## 🔧 Troubleshooting

**Problem**: Login fails with "Invalid username or password"
- **Solution**: Double-check credentials from the login page expander, or verify MySQL user exists

**Problem**: "Access denied" message after login
- **Solution**: Your role doesn't have permission for that table/operation. Check role permissions above.

**Problem**: Dashboard won't start
- **Solution**: Run `pip install -r requirements.txt` first

**Problem**: "Connection refused" or database error
- **Solution**: Ensure MySQL server is running and `.env` file has correct credentials

**Problem**: Date errors
- **Solution**: Use the date picker or format yyyy-mm-dd

**Problem**: Foreign key constraint error
- **Solution**: Create referenced records first (e.g., customer before order)

**Problem**: Can't see my changes
- **Solution**: The page auto-refreshes after operations

**Problem**: Logged in as wrong role
- **Solution**: Click "Logout" button in sidebar and log in again with different credentials

## 📊 Recommended Workflow

### Adding New Data
1. Start with independent tables (customer, product, supplier)
2. Then add relationship data (addresses, emails)
3. Finally add transactional data (orders, payments)

### Analyzing Data
1. Check raw data with Read operation
2. Use visualizations for insights
3. Cross-reference multiple charts

### Updating Records
1. Use Read to find the record
2. Note the index number
3. Use Update and select that index

## 🎨 Customization Ideas

Want to extend the dashboard? Try:
- Adding new visualizations based on your queries
- Creating custom filters in Read operations
- Building aggregate reports
- Exporting data to CSV (add pandas `.to_csv()`)

## ✅ Quick Test Checklist

Run through these to verify everything works:

### Initial Setup & Login
- [ ] Dashboard opens in browser
- [ ] Login page displays correctly
- [ ] Can log in as `admin_user`
- [ ] See welcome message with role name

### CRUD Operations Test (as Admin)
- [ ] Select "CRUD Operations" mode
- [ ] Choose `customer` table
- [ ] View customer table (Read operation)
- [ ] Create a new test customer
- [ ] Update the test customer
- [ ] Delete the test customer

### Visualizations Test
- [ ] Switch to "Visualizations" mode
- [ ] View Customer Age Distribution chart
- [ ] View Product Sales Analysis chart
- [ ] View Order Status Overview

### Role-Based Access Test
- [ ] Logout from admin account
- [ ] Login as `sales_manager`
- [ ] Verify limited table access
- [ ] Try to update an order (should work)
- [ ] Logout and return to admin

### View Data Mode Test
- [ ] Login as `marketing_team`
- [ ] Select "View Data" mode
- [ ] View `marketinganalyticsview`
- [ ] Use search/filter functionality
- [ ] Download data as CSV

## 📚 Next Steps

Once comfortable with basics:
1. **Test all 6 user roles** to understand permission boundaries
2. **Explore role-specific features** (e.g., admin audit tables, warehouse inventory management)
3. **Try all database views** in "View Data" mode
4. **Experiment with all 8 visualizations** available to different roles
5. **Review audit logs** (as admin) to see how operations are tracked
6. **Practice with complex tables** that have foreign key relationships

## 🔐 Security Features

Your dashboard includes:
- ✅ **Role-Based Access Control (RBAC)** - 6 distinct user roles
- ✅ **MySQL Native Authentication** - Credentials verified by database
- ✅ **SQL Injection Prevention** - Parameterized queries throughout
- ✅ **Audit Trail Logging** - All operations tracked (admin visible)
- ✅ **Granular Permissions** - Table and operation-level access control
- ✅ **Environment Variable Config** - Sensitive data in `.env` file
- ✅ **Session Management** - Secure login/logout functionality

---

**Need Help?** Check the full [README.md](README.md) for detailed documentation or [SECURITY_SETUP.md](../SECURITY_SETUP.md) for role configuration details.
