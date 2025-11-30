-- ========================================================================
-- DATABASE SECURITY IMPLEMENTATION
-- E-Commerce Database Security Measures
-- ========================================================================

-- ========================================================================
-- 1. USER ACCOUNT CREATION
-- ========================================================================
-- Note: In SQLite, user management is limited. 
-- The following examples use standard SQL syntax that would work in MySQL/PostgreSQL/Oracle

-- Create different user roles
-- CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'SecurePass123!';
-- CREATE USER 'sales_manager'@'localhost' IDENTIFIED BY 'SalesPass456!';
-- CREATE USER 'customer_service'@'localhost' IDENTIFIED BY 'CSPass789!';
-- CREATE USER 'warehouse_staff'@'localhost' IDENTIFIED BY 'WarehousePass012!';
-- CREATE USER 'marketing_team'@'localhost' IDENTIFIED BY 'MarketPass345!';
-- CREATE USER 'delivery_coordinator'@'localhost' IDENTIFIED BY 'DeliveryPass678!';

-- ========================================================================
-- 2. VIEWS FOR ACCESS CONTROL
-- ========================================================================

-- 2.1 Customer Service View - Limited customer information (no sensitive financial data)
CREATE VIEW CustomerServiceView AS
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.RegistrationDate,
    c.LoyaltyPoints,
    c.AccountStatus
FROM customer c;

-- 2.2 Customer Contact View - For customer service to contact customers
CREATE VIEW CustomerContactView AS
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    ce.CustomerEmail,
    cc.PhoneNumber
FROM customer c
LEFT JOIN customerEmail ce ON c.CustomerID = ce.CustomerID
LEFT JOIN customerContact cc ON c.CustomerID = cc.CustomerID;

-- 2.3 Order Summary View - For sales managers (no customer personal details)
CREATE VIEW OrderSummaryView AS
SELECT 
    o.OrderID,
    o.OrderDate,
    o.TotalAmount,
    o.ShippingFee,
    o.OrderStatus,
    o.CustomerID
FROM orders o;

-- 2.4 Product Inventory View - For warehouse staff
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

-- 2.5 Active Orders Delivery View - For delivery coordinators
CREATE VIEW ActiveDeliveryView AS
SELECT 
    d.DeliveryID,
    d.DeliveryDate,
    d.DeliveryStatus,
    d.DeliveryFee,
    o.OrderID,
    o.TrackingID,
    a.Street,
    a.City,
    a.ZipCode
FROM delivery d
JOIN orders o ON d.OrderID = o.OrderID
JOIN address a ON d.AddressID = a.AddressID
WHERE d.DeliveryStatus IN ('Pending', 'In Transit', 'Out for Delivery');

-- 2.6 Marketing Analytics View - For marketing team (aggregated data only)
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
GROUP BY p.ProductID, p.ProductName, pa.SalesCount, pa.LastMonthSales, 
         pa.IsBestSeller, pa.IsNewRelease;

-- 2.7 Sensitive Payment Information View - Masked credit card data
CREATE VIEW MaskedPaymentView AS
SELECT 
    p.PaymentID,
    p.PaymentDate,
    p.Amount,
    p.PaymentStatus,
    c.CardType,
    '****-****-****-' || SUBSTR(c.CardNumber, -4) AS MaskedCardNumber,
    c.ExpiryDate,
    p.CustomerID
FROM payment p
LEFT JOIN card c ON p.CardID = c.CardID;

-- 2.8 Active Customers View - Only active accounts
CREATE VIEW ActiveCustomersView AS
SELECT 
    CustomerID,
    FirstName,
    LastName,
    RegistrationDate,
    LoyaltyPoints
FROM customer
WHERE AccountStatus = 'Active';

-- 2.9 Supplier Information View - Limited to essential business data
CREATE VIEW SupplierBusinessView AS
SELECT 
    s.SupplierID,
    s.SupplierName,
    se.SupplierEmail,
    sc.PhoneNumber
FROM supplier s
LEFT JOIN supplierEmail se ON s.SupplierID = se.SupplierID
LEFT JOIN supplierContact sc ON s.SupplierID = sc.SupplierID;

-- 2.10 Return Management View - For customer service handling returns
CREATE VIEW ReturnManagementView AS
SELECT 
    r.ReturnID,
    r.ReturnDate,
    r.ReturnAmount,
    r.ReturnStatus,
    r.Reason,
    r.OrderID,
    r.ProductID,
    p.ProductName
FROM returnTable r
JOIN product p ON r.ProductID = p.ProductID;

-- ========================================================================
-- 3. GRANT PRIVILEGES - ROLE-BASED ACCESS CONTROL
-- ========================================================================

-- 3.1 Admin User - Full access to all tables
-- GRANT ALL PRIVILEGES ON customer TO admin_user;
-- GRANT ALL PRIVILEGES ON product TO admin_user;
-- GRANT ALL PRIVILEGES ON orders TO admin_user;
-- GRANT ALL PRIVILEGES ON payment TO admin_user;
-- GRANT ALL PRIVILEGES ON supplier TO admin_user;

-- 3.2 Sales Manager - Read access to orders and customers, update orders
-- GRANT SELECT ON customer TO sales_manager;
-- GRANT SELECT, UPDATE ON orders TO sales_manager;
-- GRANT SELECT ON OrderSummaryView TO sales_manager;
-- GRANT SELECT ON product TO sales_manager;
-- GRANT SELECT ON MarketingAnalyticsView TO sales_manager;

-- 3.3 Customer Service - Limited customer data access
-- GRANT SELECT ON CustomerServiceView TO customer_service;
-- GRANT SELECT ON CustomerContactView TO customer_service;
-- GRANT SELECT, UPDATE ON ReturnManagementView TO customer_service;
-- GRANT SELECT ON orders TO customer_service;
-- GRANT UPDATE(AccountStatus) ON customer TO customer_service;

-- 3.4 Warehouse Staff - Product and inventory management
-- GRANT SELECT, UPDATE ON ProductInventoryView TO warehouse_staff;
-- GRANT SELECT, UPDATE ON product TO warehouse_staff;
-- GRANT SELECT ON orders TO warehouse_staff;
-- GRANT SELECT, INSERT, UPDATE ON supplierProduct TO warehouse_staff;

-- 3.5 Marketing Team - Read-only analytics access
-- GRANT SELECT ON MarketingAnalyticsView TO marketing_team;
-- GRANT SELECT ON product TO marketing_team;
-- GRANT SELECT ON rating TO marketing_team;
-- GRANT SELECT ON productAnalytics TO marketing_team;

-- 3.6 Delivery Coordinator - Delivery management only
-- GRANT SELECT ON ActiveDeliveryView TO delivery_coordinator;
-- GRANT SELECT, UPDATE ON delivery TO delivery_coordinator;
-- GRANT SELECT ON orders TO delivery_coordinator;
-- GRANT SELECT ON address TO delivery_coordinator;

-- ========================================================================
-- 4. COLUMN-LEVEL SECURITY - Restricting specific columns
-- ========================================================================

-- Allow customer service to update only specific columns
-- GRANT UPDATE(LoyaltyPoints, AccountStatus) ON customer TO customer_service;

-- Allow warehouse to update only stock-related columns
-- GRANT UPDATE(StockStatus) ON product TO warehouse_staff;

-- ========================================================================
-- 5. GRANT WITH GRANT OPTION - Delegation
-- ========================================================================

-- Allow sales manager to grant read access to their team
-- GRANT SELECT ON OrderSummaryView TO sales_manager WITH GRANT OPTION;
-- GRANT SELECT ON customer TO sales_manager WITH GRANT OPTION;

-- ========================================================================
-- 6. REVOKE PRIVILEGES - Removing access
-- ========================================================================

-- Example: Revoke insert privilege from a user
-- REVOKE INSERT ON orders FROM customer_service;

-- Revoke all privileges from a user who left
-- REVOKE ALL PRIVILEGES ON customer FROM former_employee;

-- Revoke only the grant option, keeping the base privilege
-- REVOKE GRANT OPTION FOR SELECT ON customer FROM sales_manager;

-- ========================================================================
-- 7. AUDIT TRAIL IMPLEMENTATION - Tracking changes
-- ========================================================================

-- 7.1 Create Audit Log Tables

-- Customer Audit Trail
CREATE TABLE customer_audit (
    AuditID          INTEGER PRIMARY KEY AUTOINCREMENT,
    CustomerID       INTEGER NOT NULL,
    ActionType       VARCHAR(20) NOT NULL CHECK(ActionType IN ('INSERT', 'UPDATE', 'DELETE')),
    OldFirstName     VARCHAR(50),
    NewFirstName     VARCHAR(50),
    OldLastName      VARCHAR(50),
    NewLastName      VARCHAR(50),
    OldAccountStatus VARCHAR(20),
    NewAccountStatus VARCHAR(20),
    OldLoyaltyPoints INTEGER,
    NewLoyaltyPoints INTEGER,
    ChangedBy        VARCHAR(50) NOT NULL,
    ChangeTimestamp  DATETIME DEFAULT CURRENT_TIMESTAMP,
    IPAddress        VARCHAR(45),
    ChangeReason     TEXT
);

-- Order Audit Trail
CREATE TABLE order_audit (
    AuditID         INTEGER PRIMARY KEY AUTOINCREMENT,
    OrderID         INTEGER NOT NULL,
    ActionType      VARCHAR(20) NOT NULL CHECK(ActionType IN ('INSERT', 'UPDATE', 'DELETE')),
    OldOrderStatus  VARCHAR(20),
    NewOrderStatus  VARCHAR(20),
    OldTotalAmount  DECIMAL(10,2),
    NewTotalAmount  DECIMAL(10,2),
    ChangedBy       VARCHAR(50) NOT NULL,
    ChangeTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    IPAddress       VARCHAR(45),
    ChangeReason    TEXT
);

-- Product Audit Trail
CREATE TABLE product_audit (
    AuditID         INTEGER PRIMARY KEY AUTOINCREMENT,
    ProductID       INTEGER NOT NULL,
    ActionType      VARCHAR(20) NOT NULL CHECK(ActionType IN ('INSERT', 'UPDATE', 'DELETE')),
    OldProductName  VARCHAR(100),
    NewProductName  VARCHAR(100),
    OldStockStatus  VARCHAR(20),
    NewStockStatus  VARCHAR(20),
    ChangedBy       VARCHAR(50) NOT NULL,
    ChangeTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    IPAddress       VARCHAR(45),
    ChangeReason    TEXT
);

-- Payment Audit Trail (Sensitive financial transactions)
CREATE TABLE payment_audit (
    AuditID         INTEGER PRIMARY KEY AUTOINCREMENT,
    PaymentID       INTEGER NOT NULL,
    ActionType      VARCHAR(20) NOT NULL CHECK(ActionType IN ('INSERT', 'UPDATE', 'DELETE')),
    OldAmount       DECIMAL(10,2),
    NewAmount       DECIMAL(10,2),
    OldPaymentStatus VARCHAR(20),
    NewPaymentStatus VARCHAR(20),
    ChangedBy       VARCHAR(50) NOT NULL,
    ChangeTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    IPAddress       VARCHAR(45),
    TransactionDetails TEXT
);

-- 7.2 Create Triggers for Automatic Audit Logging

-- Customer Update Trigger
CREATE TRIGGER customer_update_audit
AFTER UPDATE ON customer
FOR EACH ROW
BEGIN
    INSERT INTO customer_audit (
        CustomerID, ActionType, 
        OldFirstName, NewFirstName,
        OldLastName, NewLastName,
        OldAccountStatus, NewAccountStatus,
        OldLoyaltyPoints, NewLoyaltyPoints,
        ChangedBy
    ) VALUES (
        OLD.CustomerID, 'UPDATE',
        OLD.FirstName, NEW.FirstName,
        OLD.LastName, NEW.LastName,
        OLD.AccountStatus, NEW.AccountStatus,
        OLD.LoyaltyPoints, NEW.LoyaltyPoints,
        'SYSTEM_USER' -- In real systems, this would be CURRENT_USER
    );
END;

-- Customer Insert Trigger
CREATE TRIGGER customer_insert_audit
AFTER INSERT ON customer
FOR EACH ROW
BEGIN
    INSERT INTO customer_audit (
        CustomerID, ActionType,
        NewFirstName, NewLastName,
        NewAccountStatus, NewLoyaltyPoints,
        ChangedBy
    ) VALUES (
        NEW.CustomerID, 'INSERT',
        NEW.FirstName, NEW.LastName,
        NEW.AccountStatus, NEW.LoyaltyPoints,
        'SYSTEM_USER'
    );
END;

-- Customer Delete Trigger
CREATE TRIGGER customer_delete_audit
BEFORE DELETE ON customer
FOR EACH ROW
BEGIN
    INSERT INTO customer_audit (
        CustomerID, ActionType,
        OldFirstName, OldLastName,
        OldAccountStatus, OldLoyaltyPoints,
        ChangedBy
    ) VALUES (
        OLD.CustomerID, 'DELETE',
        OLD.FirstName, OLD.LastName,
        OLD.AccountStatus, OLD.LoyaltyPoints,
        'SYSTEM_USER'
    );
END;

-- Order Update Trigger
CREATE TRIGGER order_update_audit
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO order_audit (
        OrderID, ActionType,
        OldOrderStatus, NewOrderStatus,
        OldTotalAmount, NewTotalAmount,
        ChangedBy
    ) VALUES (
        OLD.OrderID, 'UPDATE',
        OLD.OrderStatus, NEW.OrderStatus,
        OLD.TotalAmount, NEW.TotalAmount,
        'SYSTEM_USER'
    );
END;

-- Product Update Trigger
CREATE TRIGGER product_update_audit
AFTER UPDATE ON product
FOR EACH ROW
BEGIN
    INSERT INTO product_audit (
        ProductID, ActionType,
        OldProductName, NewProductName,
        OldStockStatus, NewStockStatus,
        ChangedBy
    ) VALUES (
        OLD.ProductID, 'UPDATE',
        OLD.ProductName, NEW.ProductName,
        OLD.StockStatus, NEW.StockStatus,
        'SYSTEM_USER'
    );
END;

-- Payment Insert Trigger (Log all payment transactions)
CREATE TRIGGER payment_insert_audit
AFTER INSERT ON payment
FOR EACH ROW
BEGIN
    INSERT INTO payment_audit (
        PaymentID, ActionType,
        NewAmount, NewPaymentStatus,
        ChangedBy, TransactionDetails
    ) VALUES (
        NEW.PaymentID, 'INSERT',
        NEW.Amount, NEW.PaymentStatus,
        'SYSTEM_USER',
        'New payment transaction created'
    );
END;

-- Payment Update Trigger
CREATE TRIGGER payment_update_audit
AFTER UPDATE ON payment
FOR EACH ROW
BEGIN
    INSERT INTO payment_audit (
        PaymentID, ActionType,
        OldAmount, NewAmount,
        OldPaymentStatus, NewPaymentStatus,
        ChangedBy
    ) VALUES (
        OLD.PaymentID, 'UPDATE',
        OLD.Amount, NEW.Amount,
        OLD.PaymentStatus, NEW.PaymentStatus,
        'SYSTEM_USER'
    );
END;

-- ========================================================================
-- 8. SECURITY LOG - Track unauthorized access attempts
-- ========================================================================

CREATE TABLE security_log (
    LogID           INTEGER PRIMARY KEY AUTOINCREMENT,
    EventType       VARCHAR(50) NOT NULL CHECK(EventType IN 
                    ('LOGIN_FAILED', 'UNAUTHORIZED_ACCESS', 'SUSPICIOUS_QUERY', 
                     'PRIVILEGE_VIOLATION', 'DATA_EXPORT')),
    UserAttempted   VARCHAR(50) NOT NULL,
    TableAccessed   VARCHAR(50),
    ActionAttempted VARCHAR(100),
    IPAddress       VARCHAR(45),
    Timestamp       DATETIME DEFAULT CURRENT_TIMESTAMP,
    Details         TEXT,
    Severity        VARCHAR(20) CHECK(Severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'))
);

-- ========================================================================
-- 9. DATA MASKING VIEWS - Hiding sensitive information
-- ========================================================================

-- 9.1 Masked Customer Data (for reporting/analytics)
CREATE VIEW MaskedCustomerView AS
SELECT 
    CustomerID,
    SUBSTR(FirstName, 1, 1) || '****' AS MaskedFirstName,
    SUBSTR(LastName, 1, 1) || '****' AS MaskedLastName,
    'XXXX-XX-' || SUBSTR(DOB, -2) AS MaskedDOB,
    Gender,
    RegistrationDate,
    LoyaltyPoints,
    AccountStatus
FROM customer;

-- 9.2 Masked Email Addresses
CREATE VIEW MaskedEmailView AS
SELECT 
    CustomerID,
    SUBSTR(CustomerEmail, 1, 3) || '****@' || 
    SUBSTR(CustomerEmail, INSTR(CustomerEmail, '@') + 1) AS MaskedEmail
FROM customerEmail;

-- 9.3 Masked Phone Numbers
CREATE VIEW MaskedPhoneView AS
SELECT 
    CustomerID,
    '***-***-' || SUBSTR(PhoneNumber, -4) AS MaskedPhone
FROM customerContact;

-- ========================================================================
-- 10. QUERY EXAMPLES - Testing Security Implementation
-- ========================================================================

-- Example 1: Customer Service viewing customer info
-- SELECT * FROM CustomerServiceView WHERE CustomerID = 1;

-- Example 2: Sales Manager checking order summary
-- SELECT * FROM OrderSummaryView WHERE OrderStatus = 'Pending';

-- Example 3: Warehouse staff checking inventory
-- SELECT * FROM ProductInventoryView WHERE StockStatus = 'Low Stock';

-- Example 4: Marketing viewing analytics
-- SELECT * FROM MarketingAnalyticsView 
-- WHERE IsBestSeller = 1 
-- ORDER BY SalesCount DESC;

-- Example 5: Viewing audit trail for a specific customer
-- SELECT * FROM customer_audit 
-- WHERE CustomerID = 1 
-- ORDER BY ChangeTimestamp DESC;

-- Example 6: Checking recent payment transactions
-- SELECT * FROM payment_audit 
-- WHERE ChangeTimestamp >= DATE('now', '-7 days')
-- ORDER BY ChangeTimestamp DESC;

-- Example 7: Viewing masked customer data for reporting
-- SELECT * FROM MaskedCustomerView;

-- Example 8: Checking security violations
-- SELECT * FROM security_log 
-- WHERE Severity IN ('HIGH', 'CRITICAL')
-- ORDER BY Timestamp DESC;

-- ========================================================================
-- 11. COMMENTS ON ADDITIONAL SECURITY MEASURES
-- ========================================================================

/*
ENCRYPTION:
- In production systems, encrypt sensitive columns like:
  * card.CardNumber
  * payment.Amount
  * customerEmail.CustomerEmail
  * customer.DOB
  
- Use database-level encryption (TDE - Transparent Data Encryption)
- Encrypt data in transit using SSL/TLS
- Encrypt backups

NETWORK SECURITY:
- Implement firewall rules to restrict database access
- Use VPN for remote database connections
- Configure allowed IP addresses for database access
- Implement proxy servers for additional security layer

AUTHENTICATION:
- Use strong password policies (minimum 12 characters, complexity requirements)
- Implement multi-factor authentication (MFA)
- Regular password rotation (every 90 days)
- Lock accounts after failed login attempts

ADDITIONAL BEST PRACTICES:
- Regular security audits
- Principle of least privilege
- Regular backup and disaster recovery testing
- Database activity monitoring
- Patch management
- Security awareness training for users
*/

-- ========================================================================
-- END OF SECURITY IMPLEMENTATION
-- ========================================================================