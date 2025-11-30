# Database Views Access Guide

This document explains how database views are integrated into the dashboard and which views are accessible to each role.

## What's New in the Dashboard

### New "View Data" Mode
The dashboard now includes a **"View Data"** mode alongside the existing "CRUD Operations" and "Visualizations" modes. This new mode allows users to:

- 📊 Browse data from database views based on their role permissions
- 🔍 Search and filter view data by any column
- 📥 Download view data as CSV files
- 📈 View statistics for numeric columns

## Views Available by Role

### 👤 **Sales Manager** (`sales_manager`)
**Accessible View:**
- ✅ `OrderSummaryView` - Summary of all orders with customer and payment information

**Purpose:** Allows sales managers to view comprehensive order summaries for sales analysis and customer relationship management.

---

### 👤 **Customer Service** (`customer_service`)
**Accessible Views:**
- ✅ `CustomerServiceView` - Customer service overview with order and return data
- ✅ `ReturnManagementView` - Return management data (with UPDATE permissions)

**Purpose:** Enables customer service representatives to:
- View customer orders and issues
- Manage product returns and refunds
- Track return statuses

---

### 👤 **Marketing Team** (`marketing_team`)
**Accessible View:**
- ✅ `MarketingAnalyticsView` - Marketing analytics and customer insights

**Purpose:** Provides marketing team with customer behavior analytics, campaign performance, and demographic data for strategic decision-making.

---

### 👤 **Delivery Coordinator** (`delivery_coordinator`)
**Accessible View:**
- ✅ `ActiveDeliveryView` - Currently active deliveries and their status

**Purpose:** Helps delivery coordinators monitor ongoing deliveries, track delivery persons, and manage delivery schedules.

---

### 👤 **Administrator** (`admin_user`)
**Accessible Views:**
- ✅ **ALL VIEWS** (including all role-specific views plus additional system views)

**Purpose:** Full system access for database administration and comprehensive oversight.

---

### 👤 **Warehouse Staff** (`warehouse_staff`)
**Accessible Views:**
- ⚠️ Currently no specific views granted (table-level access only)

**Suggestion:** Consider creating a `WarehouseInventoryView` for better inventory management.

---

## How to Use Views in the Dashboard

### Step 1: Login
Log in with your role credentials (e.g., `sales_manager` / `SalesPass456!`)

### Step 2: Select "View Data" Mode
In the sidebar, select **"View Data"** from the mode selection radio buttons.

### Step 3: Choose a View
Select from the available views in the dropdown menu. Only views you have permission to access will appear.

### Step 4: Explore the Data
- **Browse:** Scroll through the data table
- **Search:** Use the search functionality to filter by column
- **Analyze:** View statistics for numeric columns
- **Export:** Download the data as CSV for external analysis

---

## Features of View Data Mode

### 🔍 Search & Filter
```
1. Select a column to search (or "All" for global search)
2. Enter your search term
3. Results update automatically
```

### 📥 CSV Export
- One-click download with timestamp
- Preserves all visible data
- Compatible with Excel, Google Sheets, etc.

### 📊 Statistics Panel
- Automatic calculation of min, max, mean, median
- Shows for all numeric columns in the view
- Helps with quick data analysis

---

## Security Model

### View Permissions
Views are protected by the same role-based access control (RBAC) as tables:

1. **Defined in:** [GrantPrivilages.sql](security/GrantPrivilages.sql)
2. **Enforced by:** MySQL database server
3. **Verified by:** Dashboard authentication system

### Example Grant Statement
```sql
-- Sales Manager can only SELECT from OrderSummaryView
GRANT SELECT ON ecommerce_db.OrderSummaryView TO 'sales_manager'@'localhost';
```

### Access Denial
If you try to access a view you don't have permission for:
- ❌ View won't appear in the dropdown
- ❌ Direct access attempts will be blocked by MySQL
- ✅ Error messages guide you to available resources

---

## Extending View Access

To grant a role access to additional views:

### 1. Edit Grant Privileges File
Open [GrantPrivilages.sql](security/GrantPrivilages.sql)

### 2. Add GRANT Statement
```sql
GRANT SELECT ON ecommerce_db.ViewName TO 'role_name'@'localhost';
```

### 3. Apply Changes
```bash
mysql -u root -p ecommerce_db < security/GrantPrivilages.sql
```

### 4. Update Dashboard Permissions (if needed)
Edit [app.py](app.py) to add the view to the role's `tables` list:

```python
'role_name': {
    'name': 'Role Display Name',
    'tables': ['existing_tables', 'NewViewName'],
    'operations': {
        'NewViewName': ['read']  # GRANT SELECT
    },
    # ...
}
```

---

## Troubleshooting

### Issue: "No views available for your role"
**Solution:** Your role doesn't have access to any views. Contact your administrator to request access.

### Issue: "Error fetching view data"
**Solutions:**
1. Check if the view exists in the database
2. Verify your role has SELECT permissions on the view
3. Check MySQL server connection
4. Review MySQL error logs

### Issue: View shows no data
**Possible Causes:**
1. View contains no records (legitimate empty result)
2. View definition references empty tables
3. JOIN conditions filter out all records

---

## Benefits of Using Views

### For End Users
✅ **Simplified Data Access** - Pre-joined, pre-filtered data
✅ **Consistent Results** - Same view definition for everyone
✅ **No SQL Required** - Easy point-and-click interface
✅ **Security** - Can't see data outside your permissions

### For Administrators
✅ **Centralized Logic** - View definitions in one place
✅ **Easier Maintenance** - Update view instead of multiple queries
✅ **Better Security** - Fine-grained access control
✅ **Performance** - Can be optimized or materialized

---

## Next Steps

1. ✅ Views integrated into dashboard with "View Data" mode
2. ✅ Role-based access control enforced
3. ✅ Search and export functionality added
4. 💡 Consider adding more role-specific views
5. 💡 Implement view-based visualizations
6. 💡 Add data refresh timestamps for views

---

**Last Updated:** December 2025
**Dashboard Version:** 2.0 (with View Support)
