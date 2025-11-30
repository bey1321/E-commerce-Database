# Audit Trail & Security Logs Guide

This document explains how administrators can access and monitor audit trails and security logs in the dashboard.

## 🔒 Admin-Only Access

Audit trails and security logs are **only accessible to administrators** (`admin_user` role). These tables track all changes and security events in the system.

---

## 📋 Available Audit Tables

### 1. **customer_audit**
**Purpose:** Tracks all changes to customer records

**Columns:**
- `AuditID` - Unique audit record ID
- `CustomerID` - Customer being modified
- `ActionType` - INSERT, UPDATE, or DELETE
- `OldFirstName` / `NewFirstName` - First name changes
- `OldLastName` / `NewLastName` - Last name changes
- `OldAccountStatus` / `NewAccountStatus` - Account status changes
- `OldLoyaltyPoints` / `NewLoyaltyPoints` - Loyalty points changes
- `ChangedBy` - User who made the change
- `ChangeTimestamp` - When the change occurred

**Use Case:** Monitor customer profile updates, account status changes, and loyalty point modifications.

---

### 2. **card_audit**
**Purpose:** Tracks changes to payment card information

**Columns:**
- `AuditID` - Unique audit record ID
- `CardID` - Card being modified
- `ActionType` - INSERT, UPDATE, or DELETE
- `OldCardNumber` / `NewCardNumber` - Card number changes
- `OldExpiryYear` / `NewExpiryYear` - Expiry year changes
- `OldExpiryMonth` / `NewExpiryMonth` - Expiry month changes
- `ChangedBy` - User who made the change
- `ChangeTimestamp` - When the change occurred

**Use Case:** Track payment card updates for security and compliance purposes.

---

### 3. **product_audit**
**Purpose:** Tracks changes to product information

**Columns:**
- `AuditID` - Unique audit record ID
- `ProductID` - Product being modified
- `ActionType` - INSERT, UPDATE, or DELETE
- `OldProductName` / `NewProductName` - Product name changes
- `OldStockStatus` / `NewStockStatus` - Stock status changes
- `ChangedBy` - User who made the change
- `ChangeTimestamp` - When the change occurred

**Use Case:** Monitor inventory changes, product updates, and stock status modifications.

---

### 4. **orders_audit**
**Purpose:** Tracks changes to order records

**Columns:**
- `AuditID` - Unique audit record ID
- `OrderID` - Order being modified
- `ActionType` - INSERT, UPDATE, or DELETE
- `OldOrderStatus` / `NewOrderStatus` - Order status changes
- `OldTotalAmount` / `NewTotalAmount` - Total amount changes
- `ChangedBy` - User who made the change
- `ChangeTimestamp` - When the change occurred

**Use Case:** Track order modifications, status updates, and price changes for fraud detection.

---

### 5. **payment_audit**
**Purpose:** Tracks changes to payment records

**Columns:**
- `AuditID` - Unique audit record ID
- `PaymentID` - Payment being modified
- `ActionType` - INSERT, UPDATE, or DELETE
- `OldAmount` / `NewAmount` - Payment amount changes
- `OldPaymentStatus` / `NewPaymentStatus` - Payment status changes
- `ChangedBy` - User who made the change
- `ChangeTimestamp` - When the change occurred

**Use Case:** Monitor payment modifications for financial auditing and fraud prevention.

---

## 🔐 Security Log Table

### **security_log**
**Purpose:** Tracks all security-related events and access attempts

**Columns:**
- `LogID` - Unique log entry ID
- `EventType` - Type of security event (e.g., "Login Attempt", "Access Denied")
- `UserAttempted` - Username that attempted the action
- `TableAccessed` - Table that was accessed (if applicable)
- `ActionAttempted` - What action was attempted
- `IPAddress` - IP address of the request
- `Timestamp` - When the event occurred
- `Details` - Additional event details
- `Severity` - Event severity level (e.g., "Info", "Warning", "Critical")

**Use Cases:**
- Track failed login attempts
- Monitor unauthorized access attempts
- Detect suspicious activity patterns
- Generate security reports
- Compliance and regulatory requirements

---

## 📊 How to Access in the Dashboard

### Step 1: Login as Administrator
```
Username: admin_user
Password: SecurePass123!
```

### Step 2: Navigate to CRUD Operations
In the sidebar, select **"CRUD Operations"** mode.

### Step 3: Quick Access Panel
You'll see an expandable panel **"🔒 Quick Access: Audit & Security Tables"** with buttons for:
- 📋 customer_audit
- 📋 card_audit
- 📋 product_audit
- 📋 orders_audit
- 📋 payment_audit
- 🔐 security_log

Click any button to quickly jump to that table.

### Step 4: View Audit Data
Select the **"Read"** operation to view all audit records in a table format.

### Step 5: Search and Filter
Use the standard table search functionality to:
- Find changes by a specific user
- Filter by date range
- Search for specific record IDs
- View changes by action type (INSERT/UPDATE/DELETE)

---

## 🔍 Common Audit Queries

### Find Recent Changes
1. Select audit table (e.g., `customer_audit`)
2. Choose "Read" operation
3. Sort by `ChangeTimestamp` (descending)

### Track User Activity
1. Select any audit table
2. Choose "Read" operation
3. Search column: `ChangedBy`
4. Enter username to find all their changes

### Monitor Specific Record
1. Select appropriate audit table
2. Choose "Read" operation
3. Search by ID column (e.g., `CustomerID`)
4. View all historical changes for that record

### Security Incident Investigation
1. Select `security_log` table
2. Choose "Read" operation
3. Filter by `Severity` = "Critical" or "Warning"
4. Review suspicious events

---

## 📈 Best Practices

### Regular Monitoring
- ✅ Review security logs daily
- ✅ Check audit trails weekly
- ✅ Investigate any unusual patterns
- ✅ Monitor failed access attempts

### Retention Policy
- 📁 Keep audit data for regulatory compliance (typically 7 years)
- 📁 Archive old security logs periodically
- 📁 Back up audit tables regularly

### Access Control
- 🔒 Only administrators should access audit tables
- 🔒 Never grant write/delete access to audit tables
- 🔒 Log all administrative access to audit data

### Alerting
- 🚨 Set up alerts for critical security events
- 🚨 Monitor for unusual access patterns
- 🚨 Track multiple failed login attempts
- 🚨 Watch for mass data modifications

---

## 🛡️ Security Features

### Read-Only for Non-Admins
- Other roles cannot see audit tables in the table list
- The `get_all_tables()` function excludes audit tables for non-admin users
- Database-level permissions enforce access control

### Immutable Records
- Audit records should never be modified or deleted
- They serve as a permanent historical record
- Only INSERT operations should be allowed

### Automated Triggers
The audit tables are populated by MySQL triggers that automatically capture:
- Every customer update
- Every payment change
- Every order modification
- Every product update
- All security events

---

## 📝 Export Audit Data

### CSV Export
1. Select the audit table
2. View the records using "Read" operation
3. Click **"📥 Download as CSV"** button
4. Save for external analysis or reporting

### Use Cases for Exports:
- Compliance reports
- Security audits
- Financial reconciliation
- Management reporting
- External system integration

---

## 🔧 Troubleshooting

### Issue: Audit table is empty
**Causes:**
- No changes have been made to trigger the audit
- Triggers may not be installed
- Database permissions issue

**Solution:**
Check if triggers exist:
```sql
SHOW TRIGGERS FROM ecommerce_db;
```

### Issue: Missing recent changes
**Causes:**
- Triggers may have failed
- Transaction was rolled back
- User bypassed application layer

**Solution:**
Review MySQL error logs and verify trigger status.

### Issue: Security log not recording events
**Causes:**
- Application not configured to log security events
- Database connection from application failed
- Table doesn't exist

**Solution:**
Verify security_log table exists and application has INSERT permissions.

---

## 📊 Sample Queries

### Find All Changes by a User
```sql
SELECT * FROM customer_audit
WHERE ChangedBy = 'sales_manager'
ORDER BY ChangeTimestamp DESC;
```

### Recent Security Events
```sql
SELECT * FROM security_log
WHERE Timestamp >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY Timestamp DESC;
```

### Critical Security Events
```sql
SELECT * FROM security_log
WHERE Severity = 'Critical'
ORDER BY Timestamp DESC;
```

### Audit Trail for Specific Customer
```sql
SELECT * FROM customer_audit
WHERE CustomerID = 123
ORDER BY ChangeTimestamp;
```

---

**Last Updated:** December 2025
**Dashboard Version:** 2.0 (with Audit Trail Access)
