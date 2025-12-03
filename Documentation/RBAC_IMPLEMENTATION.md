# Role-Based Access Control (RBAC) Implementation

## Overview
The Streamlit dashboard now implements **table-specific, operation-level permissions** that exactly match the MySQL GRANT statements defined in `security/GrantPrivilages.sql`.

## How It Works

### 1. Authentication
- Users log in with their MySQL database credentials
- The app authenticates by attempting a database connection
- User credentials are stored in `st.session_state` for the session

### 2. Table-Specific Permissions
Each role has a dictionary mapping table names to allowed operations:
```python
'operations': {
    'table_name': ['read', 'update'],  # Specific permissions per table
    'another_table': ['read']
}
```

### 3. Permission Checking
The `can_perform_operation(role, operation, table_name)` function checks:
- If the role exists
- If the role has access to the specific table
- If the specific operation is allowed on that table

## Role Permissions Matrix

### Admin User (admin_user)
**MySQL Grant:** `GRANT ALL PRIVILEGES ON ecommerce_db.*`
**App Access:**
- Tables: All tables in database
- Operations: Create, Read, Update, Delete on all tables
- Visualizations: All analytics

---

### Sales Manager (sales_manager)
**MySQL Grants:**
```sql
GRANT SELECT ON customer
GRANT SELECT, UPDATE ON orders
GRANT SELECT ON product
GRANT SELECT ON orderProduct
GRANT SELECT ON payment
GRANT SELECT ON OrderSummaryView
```

**App Access:**
| Table | Create | Read | Update | Delete |
|-------|--------|------|--------|--------|
| customer | ❌ | ✅ | ❌ | ❌ |
| orders | ❌ | ✅ | ✅ | ❌ |
| product | ❌ | ✅ | ❌ | ❌ |
| orderProduct | ❌ | ✅ | ❌ | ❌ |
| payment | ❌ | ✅ | ❌ | ❌ |
| OrderSummaryView | ❌ | ✅ | ❌ | ❌ |

**Visualizations:** Customer analytics, order analytics, payment status

---

### Customer Service (customer_service)
**MySQL Grants:**
```sql
GRANT SELECT ON customer
GRANT SELECT ON orders
GRANT SELECT ON product
GRANT SELECT ON returnTable
GRANT SELECT ON payment
GRANT SELECT ON CustomerServiceView
GRANT SELECT, UPDATE ON ReturnManagementView
```

**App Access:**
| Table | Create | Read | Update | Delete |
|-------|--------|------|--------|--------|
| customer | ❌ | ✅ | ❌ | ❌ |
| orders | ❌ | ✅ | ❌ | ❌ |
| product | ❌ | ✅ | ❌ | ❌ |
| returnTable | ❌ | ✅ | ❌ | ❌ |
| payment | ❌ | ✅ | ❌ | ❌ |
| CustomerServiceView | ❌ | ✅ | ❌ | ❌ |
| ReturnManagementView | ❌ | ✅ | ✅ | ❌ |

**Visualizations:** Customer status, order status

---

### Warehouse Staff (warehouse_staff)
**MySQL Grants:**
```sql
GRANT SELECT, UPDATE ON product
GRANT SELECT, INSERT, UPDATE ON supplierProduct
GRANT SELECT ON supplier
GRANT SELECT ON productAnalytics
```

**App Access:**
| Table | Create | Read | Update | Delete |
|-------|--------|------|--------|--------|
| product | ❌ | ✅ | ✅ | ❌ |
| supplierProduct | ✅ | ✅ | ✅ | ❌ |
| supplier | ❌ | ✅ | ❌ | ❌ |
| productAnalytics | ❌ | ✅ | ❌ | ❌ |

**Visualizations:** Product stock, product sales

---

### Marketing Team (marketing_team)
**MySQL Grants:**
```sql
GRANT SELECT ON MarketingAnalyticsView
GRANT SELECT ON product
GRANT SELECT ON productAnalytics
GRANT SELECT ON customer
GRANT SELECT ON orders
GRANT SELECT ON discount
```

**App Access:**
| Table | Create | Read | Update | Delete |
|-------|--------|------|--------|--------|
| MarketingAnalyticsView | ❌ | ✅ | ❌ | ❌ |
| product | ❌ | ✅ | ❌ | ❌ |
| productAnalytics | ❌ | ✅ | ❌ | ❌ |
| customer | ❌ | ✅ | ❌ | ❌ |
| orders | ❌ | ✅ | ❌ | ❌ |
| discount | ❌ | ✅ | ❌ | ❌ |

**Visualizations:** All analytics (full read-only analytics access)

---

### Delivery Coordinator (delivery_coordinator)
**MySQL Grants:**
```sql
GRANT SELECT, UPDATE ON delivery
GRANT SELECT ON deliveryPerson
GRANT SELECT ON orders
GRANT SELECT ON customer
GRANT SELECT ON address
GRANT SELECT ON customerAddress
GRANT SELECT ON ActiveDeliveryView
```

**App Access:**
| Table | Create | Read | Update | Delete |
|-------|--------|------|--------|--------|
| delivery | ❌ | ✅ | ✅ | ❌ |
| deliveryPerson | ❌ | ✅ | ❌ | ❌ |
| orders | ❌ | ✅ | ❌ | ❌ |
| customer | ❌ | ✅ | ❌ | ❌ |
| address | ❌ | ✅ | ❌ | ❌ |
| customerAddress | ❌ | ✅ | ❌ | ❌ |
| ActiveDeliveryView | ❌ | ✅ | ❌ | ❌ |

**Visualizations:** Order status

---

## Usage Instructions

### 1. Login
```
URL: http://localhost:8501
Username: sales_manager (or any other role)
Password: SalesPass456! (role-specific password)
```

### 2. Available Operations
After login, the sidebar shows:
- **Tables:** Only tables the role has access to
- **Operations:** Only operations allowed for the selected table
- **Visualizations:** Only authorized analytics

### 3. Permission Enforcement
- **Sidebar Level:** Operations not allowed are hidden from the UI
- **Database Level:** MySQL enforces permissions even if UI bypassed
- **Error Handling:** Clear error messages if permission denied

## Security Features

1. **Least Privilege Principle:** Each role has minimal required permissions
2. **Defense in Depth:** Both app-level and database-level enforcement
3. **Audit Trail:** MySQL can track all operations via user accounts
4. **Session-Based:** Credentials not stored permanently
5. **Parameterized Queries:** SQL injection prevention

## Testing Role Permissions

### Test Delivery Coordinator (Previously Had Bug)
1. Login as: `delivery_coordinator` (with password from userAccountCreation.sql)
2. Select table: `address`
3. Expected: Only "Read" operation visible
4. Previous Bug: "Update" was visible but failed with MySQL error
5. Fixed: "Update" no longer appears in the UI for address table

### Test Sales Manager
1. Login as: `sales_manager` (with password from userAccountCreation.sql)
2. Select table: `orders`
3. Expected: "Read" and "Update" operations visible
4. Select table: `customer`
5. Expected: Only "Read" operation visible

### Test Warehouse Staff
1. Login as: `warehouse_staff` (with password from userAccountCreation.sql)
2. Select table: `supplierProduct`
3. Expected: "Create", "Read", and "Update" visible
4. Select table: `product`
5. Expected: "Read" and "Update" visible (no Create)

## Troubleshooting

### Error: "UPDATE command denied"
**Cause:** App permissions don't match MySQL grants
**Solution:** Check `ROLE_PERMISSIONS` in `app.py` matches `GrantPrivilages.sql`

### Can't See Expected Tables
**Cause:** Role not configured in `ROLE_PERMISSIONS`
**Solution:** Add role with correct table list

### Operation Button Missing
**Expected Behavior:** If operation not allowed, button won't appear
**How to Fix:** Update role's operations dictionary in `ROLE_PERMISSIONS`

## Code Reference

**Permission Configuration:** [app.py:18-91](app.py#L18-L91)
**Permission Checker:** [app.py:158-177](app.py#L158-L177)
**Login Page:** [app.py:179-213](app.py#L179-L213)
**Operation Filtering:** [app.py:996-1019](app.py#L996-L1019)

## Maintenance

When updating MySQL grants:
1. Update `security/GrantPrivilages.sql`
2. Run the SQL script: `mysql -u root -p ecommerce_db < security/GrantPrivilages.sql`
3. Update `ROLE_PERMISSIONS` in `app.py` to match
4. Test the role in the dashboard
5. Document changes in this file

---

**Last Updated:** 2025-12-01
**Status:** ✅ All role permissions match MySQL grants exactly
