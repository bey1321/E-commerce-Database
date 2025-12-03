# DATABASE SECURITY IMPLEMENTATION

## Overview

This section documents the comprehensive security measures implemented for the E-Commerce database in MySQL Workbench. The security framework encompasses multiple layers of protection including Role-Based Access Control (RBAC), view-based access restrictions, comprehensive audit trails, automated trigger-based logging, and data masking techniques.

The implementation follows industry best practices and addresses key security principles:
- **Least Privilege Principle:** Users receive only the minimum permissions necessary
- **Defense in Depth:** Multiple security layers protect sensitive data
- **Accountability:** All changes are logged with user attribution
- **Data Privacy:** Sensitive information is masked for unauthorized viewers
- **Non-Repudiation:** Complete audit trails prevent denial of actions

---

## 1. ROLE-BASED ACCESS CONTROL (RBAC)

### 1.1 Overview of RBAC

Role-Based Access Control (RBAC) is a security paradigm that restricts database access based on user roles within an organization. Instead of granting permissions to individual users, permissions are assigned to roles, and users are assigned to appropriate roles.

**Benefits of RBAC:**
- **Simplified administration:** Manage permissions at the role level rather than individual user level
- **Least privilege enforcement:** Users receive only necessary permissions
- **Consistency:** All users in a role have identical permissions
- **Scalability:** Easy to onboard new users by assigning them to existing roles
- **Audit trail clarity:** Actions can be traced to specific roles and users

### 1.2 User Account Creation

Six distinct user accounts were created to represent different operational roles within the e-commerce organization. Each account is protected with strong password authentication.

**Implementation Code:**

```sql
USE ecommerce_db;

-- Create Users for E-Commerce Roles
-- Note: Replace 'your_secure_password' with strong passwords before deploying
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'your_secure_password';
CREATE USER 'sales_manager'@'localhost' IDENTIFIED BY 'your_secure_password';
CREATE USER 'customer_service'@'localhost' IDENTIFIED BY 'your_secure_password';
CREATE USER 'warehouse_staff'@'localhost' IDENTIFIED BY 'your_secure_password';
CREATE USER 'marketing_team'@'localhost' IDENTIFIED BY 'your_secure_password';
CREATE USER 'delivery_coordinator'@'localhost' IDENTIFIED BY 'your_secure_password';
```

**Important:** The actual passwords are configured in `security/userAccountCreation.sql`. Always change default passwords before production deployment!

**MySQL Security Note:** The `@'localhost'` designation restricts these accounts to local connections only, preventing remote access unless explicitly configured. This adds an additional layer of network-based security.

### 1.3 Role Definitions and Permissions

Each role has carefully designed permissions aligned with job responsibilities:

---

#### 1.3.1 Admin User (Database Administrator)

**Role Description:** Complete database administration with full control over all database objects.

**Business Justification:** Database administrators require unrestricted access for maintenance, schema modifications, backup operations, and emergency interventions.

**Permissions:**

```sql
GRANT ALL PRIVILEGES ON ecommerce_db.* TO 'admin_user'@'localhost';
```

**Access Level:**
- Full SELECT, INSERT, UPDATE, DELETE on all tables
- CREATE, ALTER, DROP privileges
- User management capabilities
- Complete view and trigger management

**Security Considerations:**
- This account should be used sparingly and only for administrative tasks
- All admin actions should be logged externally
- Admin credentials must be stored securely with restricted access
- Multi-factor authentication recommended for admin access

---

#### 1.3.2 Sales Manager

**Role Description:** Sales personnel who manage orders, view customer data, and track sales performance.

**Business Justification:** Sales managers need to view customer information and update order statuses, but should not modify customer records or access warehouse operations.

**Permissions:**

```sql
-- Sales Manager: Read and update orders, read customers
GRANT SELECT ON ecommerce_db.customer TO 'sales_manager'@'localhost';
GRANT SELECT, UPDATE ON ecommerce_db.orders TO 'sales_manager'@'localhost';
GRANT SELECT ON ecommerce_db.product TO 'sales_manager'@'localhost';
GRANT SELECT ON ecommerce_db.orderProduct TO 'sales_manager'@'localhost';
GRANT SELECT ON ecommerce_db.payment TO 'sales_manager'@'localhost';
GRANT SELECT ON ecommerce_db.OrderSummaryView TO 'sales_manager'@'localhost';
```

**Capabilities:**
- **Read:** Customer profiles, product catalog, order details, payment information
- **Update:** Order status and order-related fields
- **Restricted:** Cannot modify customer data, products, or payment records

**Use Cases:**
- Update order status (Processing → Shipped → Delivered)
- View customer order history for sales support
- Access payment status to confirm order completion
- Generate sales reports using OrderSummaryView

---

#### 1.3.3 Customer Service

**Role Description:** Customer support representatives who handle inquiries, complaints, and return requests.

**Business Justification:** Customer service needs to view customer information and manage returns but should not modify financial or order data.

**Permissions:**

```sql
-- Customer Service: Limited access with necessary SELECT permissions
GRANT SELECT ON ecommerce_db.customer TO 'customer_service'@'localhost';
GRANT SELECT ON ecommerce_db.orders TO 'customer_service'@'localhost';
GRANT SELECT ON ecommerce_db.product TO 'customer_service'@'localhost';
GRANT SELECT ON ecommerce_db.returnTable TO 'customer_service'@'localhost';
GRANT SELECT ON ecommerce_db.payment TO 'customer_service'@'localhost';
GRANT SELECT ON ecommerce_db.CustomerServiceView TO 'customer_service'@'localhost';
GRANT SELECT, UPDATE ON ecommerce_db.ReturnManagementView TO 'customer_service'@'localhost';
```

**Capabilities:**
- **Read-Only Access:** Customer profiles, orders, products, returns, payment status
- **Update Access:** Return status and refund amounts through ReturnManagementView
- **Restricted:** Cannot directly modify customer records, orders, or payments

**Use Cases:**
- Respond to customer inquiries about order status
- Process return requests and update return status (Pending → Approved → Completed)
- View payment information to verify transaction status
- Access customer contact details for communication

**Security Controls:**
- Cannot delete customer accounts
- Cannot modify order totals or payment amounts
- Cannot access warehouse, supplier, or delivery personnel information
- Updates restricted to return management only

---

#### 1.3.4 Warehouse Staff

**Role Description:** Inventory management personnel responsible for stock levels and supplier relationships.

**Business Justification:** Warehouse staff manage inventory but should not access customer personal information or order details.

**Permissions:**

```sql
-- Warehouse Staff: Product management with necessary SELECT permissions
GRANT SELECT, UPDATE ON ecommerce_db.product TO 'warehouse_staff'@'localhost';
GRANT SELECT, INSERT, UPDATE ON ecommerce_db.supplierProduct TO 'warehouse_staff'@'localhost';
GRANT SELECT ON ecommerce_db.supplier TO 'warehouse_staff'@'localhost';
GRANT SELECT ON ecommerce_db.productAnalytics TO 'warehouse_staff'@'localhost';
```

**Capabilities:**
- **Read/Write:** Product information (stock levels, descriptions)
- **Full Access:** Supplier-product relationships
- **Read-Only:** Supplier details, product analytics
- **No Access:** Customer data, orders, payments, deliveries

**Use Cases:**
- Update stock quantities when inventory arrives
- Manage supplier-product relationships
- View product performance analytics
- Update product details (weight, dimensions, SKU)

**Security Controls:**
- Cannot view customer personal information
- Cannot access order or payment data
- Cannot modify supplier information (read-only)
- Restricted to inventory and supplier management

---

#### 1.3.5 Marketing Team

**Role Description:** Marketing personnel who analyze customer behavior and product performance for campaigns.

**Business Justification:** Marketing needs analytics data but should not view complete customer personal details or modify any data.

**Permissions:**

```sql
-- Marketing Team: Analytics only
GRANT SELECT ON ecommerce_db.MarketingAnalyticsView TO 'marketing_team'@'localhost';
GRANT SELECT ON ecommerce_db.product TO 'marketing_team'@'localhost';
GRANT SELECT ON ecommerce_db.productAnalytics TO 'marketing_team'@'localhost';
GRANT SELECT ON ecommerce_db.customer TO 'marketing_team'@'localhost';
GRANT SELECT ON ecommerce_db.orders TO 'marketing_team'@'localhost';
GRANT SELECT ON ecommerce_db.discount TO 'marketing_team'@'localhost';
```

**Capabilities:**
- **Read-Only Access:** All granted tables and views
- **Primary Tool:** MarketingAnalyticsView for aggregated insights
- **No Modification Rights:** Cannot UPDATE, INSERT, or DELETE any data

**Use Cases:**
- Analyze product sales trends and customer purchasing patterns
- Identify best-selling products and new releases
- Evaluate discount effectiveness
- Generate customer segmentation reports
- Track average ratings and review counts

**Security Controls:**
- Strictly read-only access
- Should use masked views for customer data (recommended future enhancement)
- Cannot modify products, prices, or customer data
- Cannot access delivery, warehouse, or supplier information

---

#### 1.3.6 Delivery Coordinator

**Role Description:** Logistics personnel managing delivery operations and tracking shipments.

**Business Justification:** Delivery coordinators need to update delivery status and view delivery-related information but should not access financial or product data.

**Permissions:**

```sql
-- Delivery Coordinator: Delivery management with necessary SELECT permissions
GRANT SELECT, UPDATE ON ecommerce_db.delivery TO 'delivery_coordinator'@'localhost';
GRANT SELECT ON ecommerce_db.deliveryPerson TO 'delivery_coordinator'@'localhost';
GRANT SELECT ON ecommerce_db.orders TO 'delivery_coordinator'@'localhost';
GRANT SELECT ON ecommerce_db.customer TO 'delivery_coordinator'@'localhost';
GRANT SELECT ON ecommerce_db.address TO 'delivery_coordinator'@'localhost';
GRANT SELECT ON ecommerce_db.customerAddress TO 'delivery_coordinator'@'localhost';
GRANT SELECT ON ecommerce_db.ActiveDeliveryView TO 'delivery_coordinator'@'localhost';
```

**Capabilities:**
- **Read/Write:** Delivery records (status updates)
- **Read-Only:** Delivery personnel, orders, customer names, addresses
- **View Access:** ActiveDeliveryView for operational dashboard
- **Restricted:** Cannot access payment, product, or warehouse information

**Use Cases:**
- Update delivery status (Pending → In Transit → Out for Delivery → Delivered)
- Assign deliveries to delivery personnel
- View customer addresses for route planning
- Track active deliveries through ActiveDeliveryView

**Security Controls:**
- Cannot modify customer or order data
- Cannot access payment or product details
- Cannot modify delivery personnel records
- Updates restricted to delivery status and assignments

---

### 1.4 Permission Activation

After granting privileges, MySQL requires flushing the privilege cache:

```sql
FLUSH PRIVILEGES;
```

This command ensures all permission changes take immediate effect across all active sessions.

---

## 2. VIEW-BASED ACCESS RESTRICTION

### 2.1 Purpose of Database Views in Security

Database views serve as virtual tables that provide controlled access to underlying data. In security contexts, views offer several critical advantages:

**Security Benefits of Views:**

1. **Column-Level Security:** Hide sensitive columns from unauthorized users
2. **Row-Level Security:** Filter records based on business rules
3. **Data Abstraction:** Simplify complex queries while restricting direct table access
4. **Minimal Exposure:** Users see only necessary data
5. **Centralized Control:** Modify view logic without changing application code

**MySQL View Architecture:**

Views in MySQL are stored query definitions. When users query a view, MySQL executes the underlying SELECT statement and returns results. Users can be granted permissions on views without accessing base tables, creating a security barrier.

### 2.2 Implementation of Security Views

---

#### 2.2.1 CustomerServiceView

**Purpose:** Provide customer service representatives with essential customer information while hiding sensitive data like date of birth.

**Security Objective:** Limit exposure of complete customer records to essential fields only.

**Implementation:**

```sql
CREATE VIEW CustomerServiceView AS
SELECT
    CustomerID,
    FirstName,
    LastName,
    RegistrationDate,
    LoyaltyPoints,
    AccountStatus
FROM customer;
```

**Excluded Sensitive Fields:**
- `DOB` (Date of Birth) - PII that customer service doesn't need
- `Gender` - Potentially sensitive demographic information

**Usage:**

```sql
-- Customer Service can query this view
SELECT * FROM CustomerServiceView
WHERE AccountStatus = 'Active'
ORDER BY LoyaltyPoints DESC;
```

**Business Value:**
- Customer service can identify customers and check account status
- Loyalty points visible for reward program support
- Reduced privacy risk by excluding DOB

---

#### 2.2.2 OrderSummaryView

**Purpose:** Provide sales managers with order information without exposing detailed payment methods or customer contact information.

**Security Objective:** Abstract order data for sales reporting while maintaining customer privacy.

**Implementation:**

```sql
CREATE VIEW OrderSummaryView AS
SELECT
    OrderID,
    OrderDate,
    TotalAmount,
    ShippingFee,
    OrderStatus,
    CustomerID
FROM orders;
```

**Usage:**

```sql
-- Sales manager can analyze order trends
SELECT
    OrderStatus,
    COUNT(*) AS OrderCount,
    SUM(TotalAmount) AS TotalRevenue
FROM OrderSummaryView
WHERE OrderDate >= '2025-01-01'
GROUP BY OrderStatus;
```

**Business Value:**
- Sales managers track order volumes and revenue
- Order status visible for pipeline analysis
- Simplified interface for sales reporting

---

#### 2.2.3 ProductInventoryView

**Purpose:** Provide warehouse staff with inventory information combined with sales analytics.

**Security Objective:** Combine product and analytics data while restricting access to customer or financial information.

**Implementation:**

```sql
CREATE VIEW ProductInventoryView AS
SELECT
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.Weight,
    p.Dimensions,
    p.StockStatus,
    pa.SalesCount,
    pa.LastMonthSales
FROM product p
LEFT JOIN productAnalytics pa ON p.ProductID = pa.ProductID;
```

**Integrated Data:**
- **Product Details:** Physical attributes (weight, dimensions)
- **Inventory Status:** Stock status (In Stock, Low Stock, Out of Stock)
- **Sales Analytics:** Performance metrics for reordering decisions

**Usage:**

```sql
-- Warehouse staff identify products needing restock
SELECT ProductID, ProductName, StockStatus, LastMonthSales
FROM ProductInventoryView
WHERE StockStatus = 'Low Stock' AND LastMonthSales > 100
ORDER BY LastMonthSales DESC;
```

**Business Value:**
- Data-driven inventory replenishment
- Visibility into product performance
- Combined operational and analytical data

---

#### 2.2.4 ActiveDeliveryView

**Purpose:** Provide delivery coordinators with real-time view of active deliveries requiring attention.

**Security Objective:** Filter deliveries to show only active ones, reducing data exposure and improving operational focus.

**Implementation:**

```sql
CREATE VIEW ActiveDeliveryView AS
SELECT
    d.DeliveryID,
    d.DeliveryDate,
    d.DeliveryTimeEstimate,
    d.DeliveryFee,
    d.DeliveryStatus,
    d.AssignedDate,
    o.OrderID,
    o.OrderDate,
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    dp.DeliveryPersonID,
    dp.DeliveryPersonName
FROM delivery d
JOIN orders o ON d.OrderID = o.OrderID
JOIN customer c ON o.CustomerID = c.CustomerID
LEFT JOIN deliveryPerson dp ON d.DeliveryPersonID = dp.DeliveryPersonID
WHERE d.DeliveryStatus IN ('Pending', 'In Transit', 'Out for Delivery');
```

**Key Features:**
- **Row-Level Filtering:** Only active deliveries (excludes Delivered, Cancelled)
- **Integrated Information:** Delivery, order, customer, and delivery person data
- **Name Concatenation:** Full customer name for easy identification

**Usage:**

```sql
-- Delivery coordinator views unassigned deliveries
SELECT DeliveryID, OrderID, CustomerName, DeliveryStatus
FROM ActiveDeliveryView
WHERE DeliveryPersonID IS NULL
ORDER BY DeliveryDate ASC;
```

**Business Value:**
- Focus on actionable deliveries only
- Quick identification of unassigned deliveries
- Simplified operational dashboard

---

#### 2.2.5 MarketingAnalyticsView

**Purpose:** Provide marketing team with product performance analytics including ratings and sales metrics.

**Security Objective:** Aggregate data for marketing analysis without exposing individual customer reviews or personal data.

**Implementation:**

```sql
CREATE VIEW MarketingAnalyticsView AS
SELECT
    p.ProductID,
    p.ProductName,
    pa.SalesCount,
    pa.LastMonthSales,
    pa.IsBestSeller,
    pa.IsNewRelease,
    AVG(r.RatingValue) AS AverageRating,
    COUNT(r.RatingID) AS TotalReviews
FROM product p
LEFT JOIN productAnalytics pa ON p.ProductID = pa.ProductID
LEFT JOIN rating r ON p.ProductID = r.ProductID
GROUP BY p.ProductID;
```

**Aggregated Metrics:**
- **Sales Performance:** Total and recent sales counts
- **Product Flags:** Best seller and new release indicators
- **Customer Sentiment:** Average rating and review count (aggregated, not individual reviews)

**Usage:**

```sql
-- Marketing identifies top-performing products
SELECT ProductName, SalesCount, AverageRating, TotalReviews
FROM MarketingAnalyticsView
WHERE IsBestSeller = TRUE
ORDER BY SalesCount DESC
LIMIT 10;
```

**Business Value:**
- Data-driven marketing campaign planning
- Product performance insights
- Customer satisfaction metrics (aggregated)

**Privacy Protection:**
- Individual customer reviews not exposed
- No customer personal information included
- Aggregated data only

---

#### 2.2.6 ReturnManagementView

**Purpose:** Comprehensive view for managing product returns, refunds, and customer service workflows.

**Security Objective:** Centralize return-related data while controlling update permissions.

**Implementation:**

```sql
CREATE VIEW ReturnManagementView AS
SELECT
    r.ReturnID,
    r.ReturnDate,
    r.RefundAmount,
    r.ReturnStatus,
    r.Reason AS ReturnReason,
    o.OrderID,
    o.OrderDate,
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    p.ProductID,
    p.ProductName,
    pay.PaymentID,
    pay.Amount AS PaymentAmount,
    pay.PaymentMethod,
    pay.PaymentStatus
FROM returnTable r
JOIN orders o ON r.OrderID = o.OrderID
JOIN customer c ON o.CustomerID = c.CustomerID
JOIN product p ON r.ProductID = p.ProductID
LEFT JOIN payment pay ON o.OrderID = pay.OrderID;
```

**Integrated Data:**
- **Return Details:** Return ID, date, status, reason, refund amount
- **Order Context:** Order ID and date
- **Customer Information:** ID and name (but not contact details)
- **Product Details:** Product ID and name
- **Payment Information:** Payment amount, method, status

**Special Permission:**
Customer service has UPDATE privileges on this view:

```sql
GRANT SELECT, UPDATE ON ecommerce_db.ReturnManagementView TO 'customer_service'@'localhost';
```

**Usage:**

```sql
-- Customer service approves a return
UPDATE ReturnManagementView
SET ReturnStatus = 'Approved',
    RefundAmount = 75.00
WHERE ReturnID = 1 AND ReturnStatus = 'Pending';

-- View pending returns
SELECT ReturnID, CustomerName, ProductName, ReturnReason, ReturnDate
FROM ReturnManagementView
WHERE ReturnStatus = 'Pending'
ORDER BY ReturnDate ASC;
```

**Business Value:**
- Streamlined return processing workflow
- Complete context for return decisions
- Audit trail through underlying table triggers

---

### 2.3 View Security in MySQL

**Access Control Mechanism:**

MySQL evaluates permissions at the view level. Users can query views without having permissions on underlying tables:

```sql
-- Customer service can query ReturnManagementView
SELECT * FROM ReturnManagementView;

-- But CANNOT directly query the base table
SELECT * FROM returnTable;  -- ERROR: Access Denied
```

**View Definer vs. Invoker:**

MySQL views can be created with different security contexts:
- **DEFINER** (default): View executes with permissions of the view creator
- **INVOKER**: View executes with permissions of the current user

Current implementation uses default DEFINER model, which is appropriate for this security design.

---

## 3. AUDIT TRAIL SYSTEM

### 3.1 Audit Logging Architecture

An audit trail is a chronological record of all activities affecting critical data. Audit logs are essential for:

**Compliance Requirements:**
- **GDPR:** Track personal data modifications
- **PCI-DSS:** Monitor payment card data access
- **SOX:** Financial data modification tracking

**Security Objectives:**
- **Accountability:** Identify who made changes and when
- **Non-Repudiation:** Prevent denial of actions
- **Forensic Analysis:** Investigate security incidents
- **Change Tracking:** Monitor data modification patterns
- **Anomaly Detection:** Identify unusual activity patterns

**Audit Architecture Design:**

```
┌─────────────────┐
│  Base Table     │
│  (customer,     │
│   orders, etc.) │
└────────┬────────┘
         │
         │ Trigger Fires on
         │ INSERT/UPDATE/DELETE
         │
         ▼
┌─────────────────┐
│  Audit Table    │
│  (customer_     │
│   audit, etc.)  │
│                 │
│  Stores:        │
│  - OLD values   │
│  - NEW values   │
│  - Timestamp    │
│  - User         │
│  - Action Type  │
└─────────────────┘
```

### 3.2 Audit Table Structures

Five audit tables track changes to critical business data:

---

#### 3.2.1 customer_audit

**Purpose:** Track all modifications to customer records including profile updates, status changes, and loyalty point adjustments.

**Implementation:**

```sql
CREATE TABLE customer_audit (
    AuditID          INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID       INT NOT NULL,
    ActionType       VARCHAR(20) NOT NULL CHECK(ActionType IN ('INSERT','UPDATE','DELETE')),
    OldFirstName     VARCHAR(50),
    NewFirstName     VARCHAR(50),
    OldLastName      VARCHAR(50),
    NewLastName      VARCHAR(50),
    OldAccountStatus VARCHAR(20),
    NewAccountStatus VARCHAR(20),
    OldLoyaltyPoints INT,
    NewLoyaltyPoints INT,
    ChangedBy        VARCHAR(50),
    ChangeTimestamp  DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**Column Descriptions:**

| Column | Purpose | Notes |
|--------|---------|-------|
| `AuditID` | Unique identifier for each audit record | Auto-incrementing primary key |
| `CustomerID` | References the affected customer | NOT a foreign key to allow orphan audits |
| `ActionType` | Type of operation | INSERT, UPDATE, or DELETE |
| `Old*` columns | Previous values before change | NULL for INSERT operations |
| `New*` columns | New values after change | NULL for DELETE operations |
| `ChangedBy` | MySQL user who performed action | Captured via `USER()` function |
| `ChangeTimestamp` | When the change occurred | Automatically set to current timestamp |

**Use Cases:**
- Track customer name changes (marriage, corrections)
- Monitor account status transitions (Active → Suspended)
- Audit loyalty point adjustments
- Investigate unauthorized profile modifications

**Sample Query:**

```sql
-- View all changes to a specific customer
SELECT
    ChangeTimestamp,
    ActionType,
    OldFirstName,
    NewFirstName,
    OldAccountStatus,
    NewAccountStatus,
    ChangedBy
FROM customer_audit
WHERE CustomerID = 1001
ORDER BY ChangeTimestamp DESC;
```

---

#### 3.2.2 card_audit

**Purpose:** Track payment card information changes with strict security monitoring.

**Implementation:**

```sql
CREATE TABLE card_audit (
    AuditID        INT AUTO_INCREMENT PRIMARY KEY,
    CardID         INT NOT NULL,
    ActionType     VARCHAR(20) NOT NULL CHECK(ActionType IN ('INSERT','UPDATE','DELETE')),
    OldCardNumber  VARCHAR(20),
    NewCardNumber  VARCHAR(20),
    OldExpiryYear  INT,
    NewExpiryYear  INT,
    OldExpiryMonth INT,
    NewExpiryMonth INT,
    ChangedBy      VARCHAR(50),
    ChangeTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**Security Considerations:**

**⚠️ CRITICAL SECURITY NOTICE:**
- Card numbers should be stored encrypted or tokenized in production
- Audit logs should store masked card numbers (e.g., XXXX-XXXX-XXXX-1234)
- Access to card_audit table should be highly restricted
- Consider separate encryption keys for audit data

**Compliance:**
- **PCI-DSS Requirement 10:** Track all access to cardholder data
- Audit logs must be protected with same rigor as card data itself

**Use Cases:**
- Detect unauthorized card information access
- Track card updates and removals
- Forensic analysis of payment fraud
- Compliance reporting

---

#### 3.2.3 product_audit

**Purpose:** Track inventory and product information changes for business intelligence and fraud detection.

**Implementation:**

```sql
CREATE TABLE product_audit (
    AuditID        INT AUTO_INCREMENT PRIMARY KEY,
    ProductID      INT NOT NULL,
    ActionType     VARCHAR(20) NOT NULL CHECK(ActionType IN ('INSERT','UPDATE','DELETE')),
    OldProductName VARCHAR(100),
    NewProductName VARCHAR(100),
    OldStockStatus VARCHAR(20),
    NewStockStatus VARCHAR(20),
    ChangedBy      VARCHAR(50),
    ChangeTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**Tracked Changes:**
- Product name modifications
- Stock status transitions (In Stock → Low Stock → Out of Stock)
- Product additions and deletions

**Use Cases:**
- Inventory management analysis
- Detect unauthorized product modifications
- Track product lifecycle (creation to deletion)
- Analyze stock status patterns

**Sample Analysis:**

```sql
-- Identify products with frequent stock status changes
SELECT
    ProductID,
    COUNT(*) AS ChangeCount,
    GROUP_CONCAT(CONCAT(OldStockStatus, '→', NewStockStatus)) AS Transitions
FROM product_audit
WHERE ActionType = 'UPDATE'
  AND ChangeTimestamp >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY ProductID
HAVING ChangeCount > 10
ORDER BY ChangeCount DESC;
```

---

#### 3.2.4 orders_audit

**Purpose:** Track order modifications including status changes and amount adjustments.

**Implementation:**

```sql
CREATE TABLE orders_audit (
    AuditID        INT AUTO_INCREMENT PRIMARY KEY,
    OrderID        INT NOT NULL,
    ActionType     VARCHAR(20) NOT NULL CHECK(ActionType IN ('INSERT','UPDATE','DELETE')),
    OldOrderStatus VARCHAR(20),
    NewOrderStatus VARCHAR(20),
    OldTotalAmount DECIMAL(10,2),
    NewTotalAmount DECIMAL(10,2),
    ChangedBy      VARCHAR(50),
    ChangeTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**Critical Monitoring:**

Order total changes should be rare and heavily scrutinized:

```sql
-- Alert: Orders with amount modifications
SELECT
    OrderID,
    OldTotalAmount,
    NewTotalAmount,
    (NewTotalAmount - OldTotalAmount) AS Difference,
    ChangedBy,
    ChangeTimestamp
FROM orders_audit
WHERE ActionType = 'UPDATE'
  AND OldTotalAmount != NewTotalAmount
ORDER BY ChangeTimestamp DESC;
```

**Use Cases:**
- Track order lifecycle (Pending → Processing → Shipped → Delivered)
- Detect unauthorized order amount modifications
- Analyze order fulfillment timelines
- Investigate disputed orders

---

#### 3.2.5 payment_audit

**Purpose:** Track all payment-related changes with high security and compliance focus.

**Implementation:**

```sql
CREATE TABLE payment_audit (
    AuditID          INT AUTO_INCREMENT PRIMARY KEY,
    PaymentID        INT NOT NULL,
    ActionType       VARCHAR(20) NOT NULL CHECK(ActionType IN ('INSERT','UPDATE','DELETE')),
    OldAmount        DECIMAL(10,2),
    NewAmount        DECIMAL(10,2),
    OldPaymentStatus VARCHAR(20),
    NewPaymentStatus VARCHAR(20),
    ChangedBy        VARCHAR(50),
    ChangeTimestamp  DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**Financial Compliance:**

Payment audits are critical for:
- **Financial reconciliation:** Match payments to orders
- **Fraud detection:** Identify unusual payment patterns
- **Refund tracking:** Monitor payment status changes to "Refunded"
- **Dispute resolution:** Provide evidence for payment disputes

**Critical Alerts:**

```sql
-- Detect payment amount modifications (potential fraud)
SELECT
    PaymentID,
    OldAmount,
    NewAmount,
    OldPaymentStatus,
    NewPaymentStatus,
    ChangedBy,
    ChangeTimestamp
FROM payment_audit
WHERE ActionType = 'UPDATE'
  AND OldAmount != NewAmount
ORDER BY ChangeTimestamp DESC;
```

**Refund Monitoring:**

```sql
-- Track all refund operations
SELECT
    PaymentID,
    OldPaymentStatus,
    NewPaymentStatus,
    NewAmount,
    ChangedBy,
    ChangeTimestamp
FROM payment_audit
WHERE NewPaymentStatus = 'Refunded'
ORDER BY ChangeTimestamp DESC;
```

---

### 3.3 Compliance and Non-Repudiation

**Non-Repudiation Principle:**

Non-repudiation ensures that a party cannot deny the authenticity of their actions. Audit tables achieve this by:

1. **Immutable Records:** Audit tables should not allow UPDATE or DELETE operations
2. **User Attribution:** `ChangedBy` field captures MySQL user via `USER()` function
3. **Timestamp Precision:** Automatic timestamp prevents time manipulation
4. **Complete Change History:** Both OLD and NEW values preserved

**Recommended Audit Table Protections:**

```sql
-- Restrict direct modifications to audit tables (recommended)
REVOKE UPDATE, DELETE ON ecommerce_db.customer_audit FROM 'admin_user'@'localhost';
REVOKE UPDATE, DELETE ON ecommerce_db.orders_audit FROM 'admin_user'@'localhost';
REVOKE UPDATE, DELETE ON ecommerce_db.product_audit FROM 'admin_user'@'localhost';
REVOKE UPDATE, DELETE ON ecommerce_db.payment_audit FROM 'admin_user'@'localhost';
REVOKE UPDATE, DELETE ON ecommerce_db.card_audit FROM 'admin_user'@'localhost';

-- Only allow SELECT and INSERT (INSERT handled by triggers)
GRANT SELECT, INSERT ON ecommerce_db.*_audit TO 'admin_user'@'localhost';
```

---

## 4. AUTOMATED AUDIT TRIGGERS

### 4.1 Trigger Architecture

Database triggers are stored procedures that automatically execute in response to specific database events (INSERT, UPDATE, DELETE). Triggers enable:

**Automation Benefits:**
- **Zero-Latency Logging:** Audit records created instantly
- **Application-Independent:** Works regardless of access method (app, SQL client, API)
- **Guaranteed Execution:** Cannot be bypassed by users
- **Consistent Logic:** Centralized audit logic, not scattered in applications

**MySQL Trigger Types:**

| Timing | Event | Use Case |
|--------|-------|----------|
| BEFORE INSERT | Before row insertion | Validate data, populate defaults |
| AFTER INSERT | After row insertion | Log new record creation |
| BEFORE UPDATE | Before row modification | Validate changes, prevent unauthorized updates |
| AFTER UPDATE | After row modification | Log modifications with OLD and NEW values |
| BEFORE DELETE | Before row deletion | Preserve deleted data in audit |
| AFTER DELETE | After row deletion | Log deletion events |

**Trigger Execution Flow:**

```
User/Application
       │
       ▼
SQL Statement (INSERT/UPDATE/DELETE)
       │
       ▼
BEFORE Trigger (validation, preprocessing)
       │
       ▼
Actual Table Modification
       │
       ▼
AFTER Trigger (audit logging, notifications)
       │
       ▼
Transaction Commit
```

### 4.2 Trigger Implementation

All triggers use a consistent delimiter change pattern for MySQL:

```sql
DELIMITER $$
-- Trigger definitions here
DELIMITER ;
```

This prevents premature statement termination when defining multi-line triggers.

---

#### 4.2.1 Customer Audit Triggers

**INSERT Trigger:**

```sql
CREATE TRIGGER customer_insert_audit
AFTER INSERT ON customer
FOR EACH ROW
BEGIN
    INSERT INTO customer_audit (
        CustomerID,
        ActionType,
        NewFirstName,
        NewLastName,
        NewAccountStatus,
        NewLoyaltyPoints,
        ChangedBy
    )
    VALUES (
        NEW.CustomerID,
        'INSERT',
        NEW.FirstName,
        NEW.LastName,
        NEW.AccountStatus,
        NEW.LoyaltyPoints,
        USER()
    );
END$$
```

**Explanation:**
- **AFTER INSERT:** Executes after successful customer creation
- **NEW keyword:** References the newly inserted row values
- **USER() function:** Captures current MySQL session user
- **ActionType 'INSERT':** Clearly identifies this as a new record

**UPDATE Trigger:**

```sql
CREATE TRIGGER customer_update_audit
AFTER UPDATE ON customer
FOR EACH ROW
BEGIN
    INSERT INTO customer_audit (
        CustomerID,
        ActionType,
        OldFirstName,
        NewFirstName,
        OldLastName,
        NewLastName,
        OldAccountStatus,
        NewAccountStatus,
        OldLoyaltyPoints,
        NewLoyaltyPoints,
        ChangedBy
    )
    VALUES (
        OLD.CustomerID,
        'UPDATE',
        OLD.FirstName,
        NEW.FirstName,
        OLD.LastName,
        NEW.LastName,
        OLD.AccountStatus,
        NEW.AccountStatus,
        OLD.LoyaltyPoints,
        NEW.LoyaltyPoints,
        USER()
    );
END$$
```

**Explanation:**
- **AFTER UPDATE:** Executes after successful update
- **OLD keyword:** References values before modification
- **NEW keyword:** References values after modification
- **Complete Change History:** Both OLD and NEW values stored for comparison

**DELETE Trigger:**

```sql
CREATE TRIGGER customer_delete_audit
BEFORE DELETE ON customer
FOR EACH ROW
BEGIN
    INSERT INTO customer_audit (
        CustomerID,
        ActionType,
        OldFirstName,
        OldLastName,
        OldAccountStatus,
        OldLoyaltyPoints,
        ChangedBy
    )
    VALUES (
        OLD.CustomerID,
        'DELETE',
        OLD.FirstName,
        OLD.LastName,
        OLD.AccountStatus,
        OLD.LoyaltyPoints,
        USER()
    );
END$$
```

**Explanation:**
- **BEFORE DELETE:** Executes before deletion (to capture OLD values)
- **Only OLD values:** NEW values don't exist for deletions
- **Preserves Deleted Data:** Maintains historical record even after deletion

---

#### 4.2.2 Card Audit Triggers

Payment card triggers follow the same pattern with focus on sensitive financial data:

**INSERT Trigger:**

```sql
CREATE TRIGGER card_insert_audit
AFTER INSERT ON card
FOR EACH ROW
BEGIN
    INSERT INTO card_audit (
        CardID,
        ActionType,
        NewCardNumber,
        NewExpiryYear,
        NewExpiryMonth,
        ChangedBy
    )
    VALUES (
        NEW.CardID,
        'INSERT',
        NEW.CardNumber,
        NEW.ExpiryYear,
        NEW.ExpiryMonth,
        USER()
    );
END$$
```

**UPDATE Trigger:**

```sql
CREATE TRIGGER card_update_audit
AFTER UPDATE ON card
FOR EACH ROW
BEGIN
    INSERT INTO card_audit (
        CardID,
        ActionType,
        OldCardNumber,
        NewCardNumber,
        OldExpiryYear,
        NewExpiryYear,
        OldExpiryMonth,
        NewExpiryMonth,
        ChangedBy
    )
    VALUES (
        OLD.CardID,
        'UPDATE',
        OLD.CardNumber,
        NEW.CardNumber,
        OLD.ExpiryYear,
        NEW.ExpiryYear,
        OLD.ExpiryMonth,
        NEW.ExpiryMonth,
        USER()
    );
END$$
```

**DELETE Trigger:**

```sql
CREATE TRIGGER card_delete_audit
BEFORE DELETE ON card
FOR EACH ROW
BEGIN
    INSERT INTO card_audit (
        CardID,
        ActionType,
        OldCardNumber,
        OldExpiryYear,
        OldExpiryMonth,
        ChangedBy
    )
    VALUES (
        OLD.CardID,
        'DELETE',
        OLD.CardNumber,
        OLD.ExpiryYear,
        OLD.ExpiryMonth,
        USER()
    );
END$$
```

---

#### 4.2.3 Product Audit Triggers

Track inventory and product information changes:

**INSERT Trigger:**

```sql
CREATE TRIGGER product_insert_audit
AFTER INSERT ON product
FOR EACH ROW
BEGIN
    INSERT INTO product_audit (
        ProductID,
        ActionType,
        NewProductName,
        NewStockStatus,
        ChangedBy
    )
    VALUES (
        NEW.ProductID,
        'INSERT',
        NEW.ProductName,
        NEW.StockStatus,
        USER()
    );
END$$
```

**UPDATE Trigger:**

```sql
CREATE TRIGGER product_update_audit
AFTER UPDATE ON product
FOR EACH ROW
BEGIN
    INSERT INTO product_audit (
        ProductID,
        ActionType,
        OldProductName,
        NewProductName,
        OldStockStatus,
        NewStockStatus,
        ChangedBy
    )
    VALUES (
        OLD.ProductID,
        'UPDATE',
        OLD.ProductName,
        NEW.ProductName,
        OLD.StockStatus,
        NEW.StockStatus,
        USER()
    );
END$$
```

**DELETE Trigger:**

```sql
CREATE TRIGGER product_delete_audit
BEFORE DELETE ON product
FOR EACH ROW
BEGIN
    INSERT INTO product_audit (
        ProductID,
        ActionType,
        OldProductName,
        OldStockStatus,
        ChangedBy
    )
    VALUES (
        OLD.ProductID,
        'DELETE',
        OLD.ProductName,
        OLD.StockStatus,
        USER()
    );
END$$
```

---

#### 4.2.4 Orders Audit Triggers

Monitor critical order lifecycle and financial modifications:

**INSERT Trigger:**

```sql
CREATE TRIGGER orders_insert_audit
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO orders_audit (
        OrderID,
        ActionType,
        NewOrderStatus,
        NewTotalAmount,
        ChangedBy
    )
    VALUES (
        NEW.OrderID,
        'INSERT',
        NEW.OrderStatus,
        NEW.TotalAmount,
        USER()
    );
END$$
```

**UPDATE Trigger:**

```sql
CREATE TRIGGER orders_update_audit
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO orders_audit (
        OrderID,
        ActionType,
        OldOrderStatus,
        NewOrderStatus,
        OldTotalAmount,
        NewTotalAmount,
        ChangedBy
    )
    VALUES (
        OLD.OrderID,
        'UPDATE',
        OLD.OrderStatus,
        NEW.OrderStatus,
        OLD.TotalAmount,
        NEW.TotalAmount,
        USER()
    );
END$$
```

**DELETE Trigger:**

```sql
CREATE TRIGGER orders_delete_audit
BEFORE DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO orders_audit (
        OrderID,
        ActionType,
        OldOrderStatus,
        OldTotalAmount,
        ChangedBy
    )
    VALUES (
        OLD.OrderID,
        'DELETE',
        OLD.OrderStatus,
        OLD.TotalAmount,
        USER()
    );
END$$
```

---

#### 4.2.5 Payment Audit Triggers

Financial transaction logging with strict monitoring:

**INSERT Trigger:**

```sql
CREATE TRIGGER payment_insert_audit
AFTER INSERT ON payment
FOR EACH ROW
BEGIN
    INSERT INTO payment_audit (
        PaymentID,
        ActionType,
        NewAmount,
        NewPaymentStatus,
        ChangedBy
    )
    VALUES (
        NEW.PaymentID,
        'INSERT',
        NEW.Amount,
        NEW.PaymentStatus,
        USER()
    );
END$$
```

**UPDATE Trigger:**

```sql
CREATE TRIGGER payment_update_audit
AFTER UPDATE ON payment
FOR EACH ROW
BEGIN
    INSERT INTO payment_audit (
        PaymentID,
        ActionType,
        OldAmount,
        NewAmount,
        OldPaymentStatus,
        NewPaymentStatus,
        ChangedBy
    )
    VALUES (
        OLD.PaymentID,
        'UPDATE',
        OLD.Amount,
        NEW.Amount,
        OLD.PaymentStatus,
        NEW.PaymentStatus,
        USER()
    );
END$$
```

**DELETE Trigger:**

```sql
CREATE TRIGGER payment_delete_audit
BEFORE DELETE ON payment
FOR EACH ROW
BEGIN
    INSERT INTO payment_audit (
        PaymentID,
        ActionType,
        OldAmount,
        OldPaymentStatus,
        ChangedBy
    )
    VALUES (
        OLD.PaymentID,
        'DELETE',
        OLD.Amount,
        OLD.PaymentStatus,
        USER()
    );
END$$
```

---

### 4.3 Before vs. After Triggers

**Design Decision:**

| Trigger Type | Purpose | Use Case |
|--------------|---------|----------|
| **BEFORE** | Data validation, preprocessing | DELETE triggers (preserve OLD values before removal) |
| **AFTER** | Audit logging, notifications | INSERT/UPDATE triggers (log after successful operation) |

**Why AFTER for INSERT/UPDATE:**
- Ensures audit records only for successful operations
- If base table operation fails, audit doesn't occur
- Maintains consistency between base and audit tables

**Why BEFORE for DELETE:**
- OLD values must be captured before row deletion
- AFTER DELETE triggers cannot access deleted row data
- Guarantees audit record creation before data loss

**Transaction Safety:**

All triggers execute within the same transaction as the base statement:

```sql
START TRANSACTION;

-- User updates customer
UPDATE customer SET FirstName = 'Jane' WHERE CustomerID = 1;

-- Trigger automatically executes:
-- INSERT INTO customer_audit (...) VALUES (...)

COMMIT;  -- Both operations commit together

-- If either fails, both rollback
ROLLBACK;  -- Both operations rollback together
```

This ensures audit integrity—you never have a base table change without a corresponding audit record.

---

## 5. DATA MASKING AND PRIVACY PROTECTION

### 5.1 Data Masking Strategy

Data masking is a technique to hide sensitive information from unauthorized users while maintaining data usability. Unlike encryption (which makes data unreadable), masking preserves data format and type.

**Data Masking Benefits:**

1. **Privacy Compliance:** Meets GDPR, CCPA requirements for data minimization
2. **Insider Threat Mitigation:** Reduces risk from employees with database access
3. **Development/Testing:** Provides realistic test data without exposing real PII
4. **Analytics:** Enables data analysis without revealing individual identities
5. **Reduced Liability:** Minimizes impact of data breaches

**Masking Strategies:**

| Strategy | Example | Use Case |
|----------|---------|----------|
| **Partial Masking** | John → J**** | Show first character only |
| **Pattern Preservation** | 555-123-4567 → ***-***-4567 | Last 4 digits visible |
| **Email Masking** | john@example.com → joh****@example.com | Preserve domain |
| **Date Masking** | 1990-05-15 → XXXX-XX-15 | Show day only |

**Implementation Approach:**

Create separate views with masking functions that users can access instead of base tables:

```
Base Table (Restricted)          Masked View (Accessible)
┌──────────────────┐            ┌──────────────────┐
│ customer         │            │ MaskedCustomer   │
│ - FirstName: John│────────────│ - FirstName: J***│
│ - Email: j@e.com │            │ - Email: j**@e.com│
│ - Phone: 555-1234│            │ - Phone: ***-1234│
└──────────────────┘            └──────────────────┘
```

### 5.2 Masked View Implementations

---

#### 5.2.1 MaskedCustomerView

**Purpose:** Protect customer names and dates of birth while allowing identification by ID.

**Implementation:**

```sql
CREATE VIEW MaskedCustomerView AS
SELECT
    CustomerID,
    CONCAT(SUBSTRING(FirstName, 1, 1), '****') AS MaskedFirstName,
    CONCAT(SUBSTRING(LastName, 1, 1), '****') AS MaskedLastName,
    CONCAT('XXXX-XX-', RIGHT(DOB, 2)) AS MaskedDOB,
    Gender,
    RegistrationDate,
    LoyaltyPoints,
    AccountStatus
FROM customer;
```

**Masking Logic:**

| Field | Original | Masked | Function |
|-------|----------|--------|----------|
| FirstName | John | J**** | `SUBSTRING(FirstName, 1, 1)` + `****` |
| LastName | Smith | S**** | `SUBSTRING(LastName, 1, 1)` + `****` |
| DOB | 1990-05-15 | XXXX-XX-15 | `'XXXX-XX-'` + `RIGHT(DOB, 2)` |

**MySQL Functions Used:**
- **SUBSTRING(str, pos, len):** Extract substring starting at position with length
- **CONCAT(str1, str2, ...):** Concatenate strings
- **RIGHT(str, len):** Extract rightmost characters

**Usage Example:**

```sql
-- Marketing team views customer demographics without PII
SELECT
    Gender,
    YEAR(RegistrationDate) AS RegistrationYear,
    AVG(LoyaltyPoints) AS AvgLoyaltyPoints,
    COUNT(*) AS CustomerCount
FROM MaskedCustomerView
WHERE AccountStatus = 'Active'
GROUP BY Gender, YEAR(RegistrationDate);
```

**Privacy Protection:**
- Individual identity obscured
- Demographic analysis still possible
- Loyalty program analytics enabled
- Birth date day visible for birthday campaigns (without year for age calculation)

---

#### 5.2.2 MaskedEmailView

**Purpose:** Protect email addresses while maintaining domain visibility for analytics.

**Implementation:**

```sql
CREATE VIEW MaskedEmailView AS
SELECT
    CustomerID,
    CONCAT(
        SUBSTRING(CustomerEmail, 1, 3),
        '****@',
        SUBSTRING_INDEX(CustomerEmail, '@', -1)
    ) AS MaskedEmail
FROM customerEmail;
```

**Masking Logic:**

| Original Email | Masked Email |
|----------------|--------------|
| john.doe@example.com | joh****@example.com |
| alice@gmail.com | ali****@gmail.com |
| bob123@corporate.co.uk | bob****@corporate.co.uk |

**MySQL Functions Used:**
- **SUBSTRING_INDEX(str, delim, count):** Extract substring before/after delimiter
  - Positive count: from left
  - Negative count: from right
  - `SUBSTRING_INDEX(email, '@', -1)` extracts domain

**Usage Example:**

```sql
-- Analyze customer email domains (corporate vs. public email providers)
SELECT
    SUBSTRING_INDEX(MaskedEmail, '@', -1) AS EmailDomain,
    COUNT(*) AS CustomerCount
FROM MaskedEmailView
GROUP BY EmailDomain
ORDER BY CustomerCount DESC;
```

**Business Value:**
- Domain-based segmentation (gmail.com vs. corporate domains)
- Email provider distribution analysis
- Campaign targeting by domain type
- Individual email addresses protected

---

#### 5.2.3 MaskedPhoneView

**Purpose:** Protect phone numbers while preserving last 4 digits for customer verification.

**Implementation:**

```sql
CREATE VIEW MaskedPhoneView AS
SELECT
    CustomerID,
    CONCAT('***-***-', RIGHT(PhoneNumber, 4)) AS MaskedPhone
FROM customerContact;
```

**Masking Logic:**

| Original Phone | Masked Phone |
|----------------|--------------|
| 555-123-4567 | ***-***-4567 |
| 800-555-1234 | ***-***-1234 |
| +1-415-555-9999 | ***-***-9999 |

**MySQL Functions Used:**
- **RIGHT(str, len):** Extract rightmost `len` characters

**Usage Example:**

```sql
-- Customer service verifies caller identity
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    mp.MaskedPhone
FROM MaskedCustomerView c
JOIN MaskedPhoneView mp ON c.CustomerID = mp.CustomerID
WHERE c.CustomerID = 1001;

-- Customer service asks: "For verification, can you confirm the last 4 digits?"
-- Display shows: ***-***-4567
```

**Security Benefits:**
- Last 4 digits sufficient for verification
- Full number protected from unauthorized viewing
- Reduces social engineering risk
- Complies with customer service best practices

---

#### 5.2.4 MaskedPaymentView

**Purpose:** Protect payment card information while enabling transaction tracking.

**Recommended Implementation:**

```sql
CREATE VIEW MaskedPaymentView AS
SELECT
    p.PaymentID,
    p.OrderID,
    p.PaymentDate,
    p.Amount,
    p.PaymentMethod,
    p.PaymentStatus,
    CONCAT('****-****-****-', RIGHT(c.CardNumber, 4)) AS MaskedCardNumber,
    CONCAT(c.ExpiryMonth, '/', c.ExpiryYear) AS Expiry
FROM payment p
LEFT JOIN card c ON p.CardID = c.CardID;
```

**Masking Logic:**
- Card numbers show last 4 digits only (PCI-DSS compliant)
- Payment amounts and status visible for transaction tracking
- Payment method visible (Credit Card, PayPal, etc.)
- Full card numbers never exposed

**PCI-DSS Compliance:**
- Displaying only last 4 digits meets PCI-DSS masking requirements
- First 6 digits (BIN) and last 4 can be displayed together if needed
- Middle digits must always be masked

---

## 6. SECURITY LOG FOR MONITORING

### 6.1 Security Log Table Structure

The `security_log` table provides centralized monitoring of security events, access attempts, and potential threats.

**Implementation:**

```sql
CREATE TABLE security_log (
    LogID           INT AUTO_INCREMENT PRIMARY KEY,
    EventType       VARCHAR(50) NOT NULL,
    UserAttempted   VARCHAR(50) NOT NULL,
    TableAccessed   VARCHAR(50),
    ActionAttempted VARCHAR(100),
    IPAddress       VARCHAR(45),
    Timestamp       DATETIME DEFAULT CURRENT_TIMESTAMP,
    Details         TEXT,
    Severity        VARCHAR(20)
);
```

**Column Descriptions:**

| Column | Type | Purpose |
|--------|------|---------|
| `LogID` | INT AUTO_INCREMENT | Unique identifier for each log entry |
| `EventType` | VARCHAR(50) | Type of security event (LOGIN_FAILED, UNAUTHORIZED_ACCESS, etc.) |
| `UserAttempted` | VARCHAR(50) | MySQL user who attempted the action |
| `TableAccessed` | VARCHAR(50) | Database table involved in the event |
| `ActionAttempted` | VARCHAR(100) | Specific action attempted (SELECT, UPDATE, DELETE) |
| `IPAddress` | VARCHAR(45) | Source IP address (IPv4 or IPv6) |
| `Timestamp` | DATETIME | When the event occurred |
| `Details` | TEXT | Additional context and error messages |
| `Severity` | VARCHAR(20) | Event severity (LOW, MEDIUM, HIGH, CRITICAL) |

### 6.2 Security Event Monitoring

**Manual Logging Example:**

```sql
-- Log a failed login attempt
INSERT INTO security_log (
    EventType,
    UserAttempted,
    IPAddress,
    Details,
    Severity
)
VALUES (
    'LOGIN_FAILED',
    'sales_manager@localhost',
    '192.168.1.100',
    'Invalid password - 3rd attempt in 5 minutes',
    'MEDIUM'
);
```

**Monitoring Queries:**

```sql
-- View recent high-severity events
SELECT
    Timestamp,
    EventType,
    UserAttempted,
    TableAccessed,
    ActionAttempted,
    Severity
FROM security_log
WHERE Severity IN ('HIGH', 'CRITICAL')
  AND Timestamp >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY Timestamp DESC;

-- Identify users with multiple failed access attempts
SELECT
    UserAttempted,
    COUNT(*) AS FailedAttempts,
    MAX(Timestamp) AS LastAttempt
FROM security_log
WHERE EventType = 'UNAUTHORIZED_ACCESS'
  AND Timestamp >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
GROUP BY UserAttempted
HAVING FailedAttempts >= 3
ORDER BY FailedAttempts DESC;
```

---

## 7. ADDITIONAL SECURITY BEST PRACTICES

While the implemented security measures provide robust protection, the following additional practices are recommended for a production environment:

### 7.1 Encryption

**Encryption at Rest (TDE - Transparent Data Encryption):**

MySQL Enterprise Edition supports TDE for encrypting tablespace files:

```sql
-- Enable encryption for specific tables (MySQL 8.0+)
ALTER TABLE customer ENCRYPTION='Y';
ALTER TABLE payment ENCRYPTION='Y';
ALTER TABLE card ENCRYPTION='Y';
```

**Encryption in Transit (SSL/TLS):**

Force encrypted connections:

```sql
-- Require SSL for all users
ALTER USER 'sales_manager'@'localhost' REQUIRE SSL;
ALTER USER 'customer_service'@'localhost' REQUIRE SSL;
```

### 7.2 Network Security

**Firewall Configuration:**
- Allow MySQL access only from application servers
- Implement IP whitelisting for database connections
- Use VPN for remote database access
- Network segmentation (database in separate VLAN)

### 7.3 Authentication Enhancements

**Password Policies:**

```sql
-- Set password expiration
ALTER USER 'sales_manager'@'localhost' PASSWORD EXPIRE INTERVAL 90 DAY;

-- Require password history
SET GLOBAL password_history = 5;

-- Require minimum password length
SET GLOBAL validate_password.length = 12;
```

**Account Lockout:**

```sql
-- Lock account after failed login attempts (MySQL 8.0+)
CREATE USER 'customer_service'@'localhost'
    IDENTIFIED BY 'password'
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LOCK_TIME 1;  -- Lock for 1 day
```

### 7.4 Backup and Recovery

- Implement encrypted backups
- Test restore procedures regularly
- Store backups in separate geographic locations
- Implement backup retention policies
- Verify backup integrity with checksums

---

## Summary

This security implementation provides comprehensive protection through:

**Access Control:**
- Six role-based user accounts with least-privilege permissions
- Granular GRANT controls aligned with job responsibilities
- Separation of duties preventing unauthorized data access

**Data Protection:**
- Multiple security views restricting column and row-level access
- Data masking protecting PII (names, emails, phone numbers, DOB)
- View-based abstraction hiding sensitive base tables

**Accountability:**
- Five comprehensive audit tables tracking all critical modifications
- 15 automated triggers ensuring zero-latency logging
- Complete OLD and NEW value preservation for forensic analysis

**Monitoring:**
- Centralized security_log for threat detection
- Event categorization by type and severity
- Foundation for SIEM integration and alerting

The implementation follows industry best practices and provides a robust foundation for database security in the e-commerce environment.
