-- ============================================================================
-- CUSTOMER SERVICE ROLE TEST FILE
-- ============================================================================
-- Purpose: Test the privileges and restrictions of the Customer Service role
-- 
-- Granted Privileges:
-- - SELECT on: customer, orders, product, returnTable, payment
-- - SELECT and UPDATE on: ReturnManagementView
--
-- Expected Behavior:
-- - Can view customer information, orders, products, returns, and payments
-- - Can update return status through ReturnManagementView
-- - Cannot modify customer records directly
-- - Cannot access warehouse, delivery, or supplier information
-- ============================================================================

-- Before running these tests, connect as Customer Service:
-- mysql -u CustomerService -p ecommerce_db

USE ecommerce_db;

-- ============================================================================
-- SECTION 1: OPERATIONS THAT SHOULD WORK (ALLOWED)
-- ============================================================================

-- Test 1: View customer profile and contact information
-- Expected: SUCCESS - Customer Service has SELECT on customer table
SELECT CustomerID, FirstName, LastName, Email, 
       RegistrationDate, AccountStatus
FROM customer 
WHERE Email LIKE '%@example.com'
LIMIT 10;

-- Test 2: View customer order history
-- Expected: SUCCESS - Customer Service has SELECT on orders table
SELECT o.OrderID, o.CustomerID, o.OrderDate, o.TotalAmount, o.OrderStatus,
       c.FirstName, c.LastName, c.Email
FROM orders o
JOIN customer c ON o.CustomerID = c.CustomerID
WHERE c.CustomerID = 1
ORDER BY o.OrderDate DESC;

-- Test 3: View product information for customer inquiries
-- Expected: SUCCESS - Customer Service has SELECT on product table
SELECT ProductID, ProductName, Weight, Dimensions, StockStatus
FROM product 
WHERE ProductID IN (1, 2, 3, 4, 5);

-- Test 4: View return requests
-- Expected: SUCCESS - Customer Service has SELECT on returnTable
SELECT ReturnID, OrderID, ReturnDate, Reason, ReturnStatus, RefundAmount
FROM returnTable
WHERE ReturnStatus IN ('Pending', 'Processing')
ORDER BY ReturnDate DESC;

-- Test 5: View returns with order and customer details
-- Expected: SUCCESS - Customer Service can join allowed tables
SELECT r.ReturnID, r.ReturnDate, r.Reason, r.ReturnStatus, r.RefundAmount,
       o.OrderID, o.OrderDate, o.TotalAmount,
       c.CustomerID, c.FirstName, c.LastName, c.Email
FROM returnTable r
JOIN orders o ON r.OrderID = o.OrderID
JOIN customer c ON o.CustomerID = c.CustomerID
WHERE r.ReturnDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- Test 6: View payment status for orders
-- Expected: SUCCESS - Customer Service has SELECT on payment table
SELECT p.PaymentID, p.OrderID, p.StatementDate, p.Amount, 
       p.PaymentMethod, p.PaymentStatus
FROM payment p
WHERE p.OrderID = 1;

-- Test 7: Update return status through view (key responsibility)
-- Expected: SUCCESS - Customer Service has UPDATE on ReturnManagementView
UPDATE ReturnManagementView 
SET ReturnStatus = 'Approved', 
    RefundAmount = 75.00
WHERE ReturnID = 1 AND ReturnStatus = 'Pending';

-- Test 8: View return management details through view
-- Expected: SUCCESS - Customer Service has SELECT on ReturnManagementView
SELECT ReturnID, OrderID, CustomerName, ReturnDate, 
       Reason, ReturnStatus, RefundAmount
FROM ReturnManagementView
WHERE ReturnStatus = 'Processing'
ORDER BY ReturnDate ASC;

-- ============================================================================
-- SECTION 2: OPERATIONS THAT SHOULD FAIL (RESTRICTED)
-- ============================================================================

-- Test 9: Attempt to update customer email directly
-- Expected: FAIL - Customer Service has only SELECT on customer, not UPDATE
UPDATE customer 
SET Email = 'updated@example.com'
WHERE CustomerID = 1;

-- Test 10: Attempt to delete a customer record
-- Expected: FAIL - Customer Service does NOT have DELETE privilege
DELETE FROM customer 
WHERE CustomerID = 999;

-- Test 11: Attempt to modify order total
-- Expected: FAIL - Customer Service has only SELECT on orders, not UPDATE
UPDATE orders 
SET TotalAmount = 200.00, 
    OrderStatus = 'Cancelled'
WHERE OrderID = 1;

-- Test 12: Attempt to insert a new return directly into table
-- Expected: FAIL - Customer Service has only SELECT on returnTable, not INSERT
INSERT INTO returnTable (OrderID, ReturnDate, Reason, ReturnStatus)
VALUES (1, NOW(), 'Defective product', 'Pending');

-- Test 13: Attempt to view delivery information
-- Expected: FAIL - Customer Service does NOT have access to delivery table
SELECT * FROM delivery 
WHERE OrderID = 1;

-- Test 14: Attempt to view supplier information
-- Expected: FAIL - Customer Service does NOT have access to supplier table
SELECT * FROM supplier;

-- Test 15: Attempt to modify product information
-- Expected: FAIL - Customer Service has only SELECT on product, not UPDATE
UPDATE product 
SET Dimensions = '10x10x10', 
    Weight = 5.0
WHERE ProductID = 1;

-- Test 16: Attempt to access warehouse analytics
-- Expected: FAIL - Customer Service does NOT have access to productAnalytics table
SELECT * FROM productAnalytics 
WHERE ProductID = 1;

-- Test 17: Attempt to modify payment records
-- Expected: FAIL - Customer Service has only SELECT on payment, not UPDATE
UPDATE payment 
SET PaymentStatus = 'Refunded' 
WHERE PaymentID = 1;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check current user privileges
SHOW GRANTS FOR CURRENT_USER();

-- Verify connection user
SELECT USER(), CURRENT_USER(), DATABASE();

-- Count pending returns needing attention
SELECT ReturnStatus, COUNT(*) as count
FROM returnTable
GROUP BY ReturnStatus;

-- ============================================================================
-- END OF CUSTOMER SERVICE ROLE TEST FILE
-- ============================================================================
