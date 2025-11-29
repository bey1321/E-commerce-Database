-- =========================================
-- ADMIN USER ROLE TEST
-- =========================================
-- Role: admin_user
-- Password: SecurePass123!
-- Granted Privileges: ALL PRIVILEGES ON ecommerce_db.*
-- Description: Full administrative access to all database objects and operations

-- Connect as: admin_user@localhost with password: SecurePass123!
USE ecommerce_db;

-- Verify current user
SELECT CURRENT_USER();
SELECT USER();

-- Check granted privileges
SHOW GRANTS FOR CURRENT_USER();


-- =========================================
-- SECTION 1: OPERATIONS THAT SHOULD WORK
-- =========================================
-- Admin has full access to everything

-- ✅ Test 1: Read any table
SELECT * FROM customer LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM product LIMIT 5;

-- ✅ Test 2: Update any table
UPDATE customer SET LoyaltyPoints = LoyaltyPoints + 10 WHERE CustomerID = 1;

-- ✅ Test 3: Insert into any table
INSERT INTO category (CategoryName) VALUES ('Test Category');

-- ✅ Test 4: Delete from any table
DELETE FROM category WHERE CategoryName = 'Test Category';

-- ✅ Test 5: Create new tables
CREATE TABLE admin_test_table (
    TestID INT PRIMARY KEY AUTO_INCREMENT,
    TestData VARCHAR(100)
);

-- ✅ Test 6: Drop tables
DROP TABLE IF EXISTS admin_test_table;

-- ✅ Test 7: Create views
CREATE OR REPLACE VIEW admin_test_view AS
SELECT CustomerID, FirstName, LastName FROM customer;

-- ✅ Test 8: Drop views
DROP VIEW IF EXISTS admin_test_view;

-- ✅ Test 9: Alter table structure
ALTER TABLE customer_audit ADD COLUMN AdminNote TEXT;
ALTER TABLE customer_audit DROP COLUMN AdminNote;

-- ✅ Test 10: Create indexes
CREATE INDEX idx_customer_lastname ON customer(LastName);
DROP INDEX idx_customer_lastname ON customer;

-- ✅ Test 11: Truncate tables (dangerous operation)
-- TRUNCATE TABLE customer_audit;  -- Uncomment to test (will delete all audit records)

-- ✅ Test 12: Complex multi-table updates
UPDATE orders o
JOIN customer c ON o.CustomerID = c.CustomerID
SET o.ShippingFee = 0
WHERE c.AccountStatus = 'Active' AND o.OrderID = 1;

-- ✅ Test 13: Complex joins across multiple tables
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(o.TotalAmount) AS TotalSpent,
    AVG(r.RatingValue) AS AvgRating
FROM customer c
LEFT JOIN orders o ON c.CustomerID = o.CustomerID
LEFT JOIN rating r ON c.CustomerID = r.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING TotalOrders > 0
ORDER BY TotalSpent DESC;

-- ✅ Test 14: Manage stored procedures (if any exist)
-- CREATE PROCEDURE test_proc() BEGIN SELECT 1; END;
-- DROP PROCEDURE IF EXISTS test_proc;

-- ✅ Test 15: Access system tables
SELECT * FROM mysql.user WHERE user LIKE '%admin%' OR user LIKE '%service%';

-- ✅ Test 16: Backup operations (show create statements)
SHOW CREATE TABLE customer;
SHOW CREATE TABLE orders;

-- ✅ Test 17: Grant/Revoke privileges to other users (admin can manage users)
-- Note: Uncomment to test user management
-- GRANT SELECT ON ecommerce_db.product TO 'test_user'@'localhost';
-- REVOKE SELECT ON ecommerce_db.product FROM 'test_user'@'localhost';


-- =========================================
-- SECTION 2: OPERATIONS THAT SHOULD WORK BUT ARE DANGEROUS
-- =========================================
-- Admin can do these, but they are high-risk operations

-- ⚠️ Warning Test 1: Drop entire tables (DANGEROUS)
-- DROP TABLE customer;  -- DO NOT UNCOMMENT unless you want to lose data!

-- ⚠️ Warning Test 2: Drop the entire database (EXTREMELY DANGEROUS)
-- DROP DATABASE ecommerce_db;  -- DO NOT UNCOMMENT!

-- ⚠️ Warning Test 3: Delete all records without WHERE clause
-- DELETE FROM customer_audit;  -- Uncomment carefully!

-- ⚠️ Warning Test 4: Update all records without WHERE clause
-- UPDATE customer SET AccountStatus = 'Deleted';  -- DO NOT RUN!


-- =========================================
-- SECTION 3: VERIFICATION QUERIES
-- =========================================

-- Verify admin has full table access
SELECT 
    TABLE_NAME, 
    TABLE_ROWS 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'ecommerce_db'
ORDER BY TABLE_NAME;

-- Verify admin can see all views
SELECT 
    TABLE_NAME 
FROM information_schema.VIEWS 
WHERE TABLE_SCHEMA = 'ecommerce_db'
ORDER BY TABLE_NAME;

-- Check database size
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
WHERE table_schema = 'ecommerce_db'
GROUP BY table_schema;

-- List all users in the system
SELECT user, host FROM mysql.user ORDER BY user;

-- Check all privileges for all e-commerce users
SELECT GRANTEE, PRIVILEGE_TYPE, TABLE_SCHEMA, TABLE_NAME
FROM information_schema.TABLE_PRIVILEGES
WHERE TABLE_SCHEMA = 'ecommerce_db'
ORDER BY GRANTEE, TABLE_NAME;


-- =========================================
-- SUMMARY
-- =========================================
-- Admin user (admin_user@localhost) has:
-- ✅ ALL PRIVILEGES on ecommerce_db database
-- ✅ Full SELECT, INSERT, UPDATE, DELETE access
-- ✅ Full DDL access (CREATE, ALTER, DROP tables/views/indexes)
-- ✅ Can manage other users' privileges
-- ✅ Can access system tables and metadata
-- ✅ Can perform backup and restore operations
-- ✅ NO RESTRICTIONS - complete database control
--
-- ⚠️  With great power comes great responsibility!
-- ⚠️  Always be careful with DROP, DELETE, and TRUNCATE operations
-- ⚠️  Consider using transactions (BEGIN/ROLLBACK/COMMIT) for safety
