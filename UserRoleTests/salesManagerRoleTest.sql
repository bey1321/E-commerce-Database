-- ============================================================================
-- SALES MANAGER ROLE TEST FILE
-- ============================================================================
-- Purpose: Test the privileges and restrictions of the Sales Manager role
-- 
-- Granted Privileges:
-- - SELECT on: customer, product, orderProduct, payment
-- - SELECT and UPDATE on: orders
--
-- Expected Behavior:
-- - Can view customer information, products, order details, and payments
-- - Can view and modify order status and information
-- - Cannot insert new records or delete existing ones
-- - Cannot access other tables like delivery, supplier, etc.
-- ============================================================================

-- Before running these tests, connect as Sales Manager:
-- mysql -u SalesManager -p ecommerce_db

USE ecommerce_db;

-- ============================================================================
-- SECTION 1: OPERATIONS THAT SHOULD WORK (ALLOWED)
-- ============================================================================

-- Test 1: View customer information
-- Expected: SUCCESS - Sales Manager has SELECT on customer table
SELECT CustomerID, FirstName, LastName, Email 
FROM customer 
WHERE CustomerID = 1;

-- Test 2: View product catalog with pricing
-- Expected: SUCCESS - Sales Manager has SELECT on product table
SELECT ProductID, ProductName, StockStatus 
FROM product 
WHERE StockStatus = 'In Stock' 
ORDER BY ProductID DESC 
LIMIT 10;

-- Test 3: View order details with products
-- Expected: SUCCESS - Sales Manager has SELECT on orders and orderProduct tables
SELECT o.OrderID, o.OrderDate, o.TotalAmount, o.OrderStatus,
       op.ProductID, op.Quantity, op.UnitPrice
FROM orders o
JOIN orderProduct op ON o.OrderID = op.OrderID
WHERE o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY o.OrderDate DESC;

-- Test 4: View payment information for orders
-- Expected: SUCCESS - Sales Manager has SELECT on payment table
SELECT p.PaymentID, p.OrderID, p.StatementDate, p.Amount, p.PaymentMethod, p.PaymentStatus
FROM payment p
JOIN orders o ON p.OrderID = o.OrderID
WHERE o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL 7 DAY);

-- Test 5: Update order status (key responsibility)
-- Expected: SUCCESS - Sales Manager has UPDATE on orders table
UPDATE orders 
SET OrderStatus = 'Processing'
WHERE OrderID = 1 AND OrderStatus = 'Pending';

-- Test 6: View total sales by customer
-- Expected: SUCCESS - Complex query using allowed tables
SELECT c.CustomerID, c.FirstName, c.LastName,
       COUNT(o.OrderID) as total_orders,
       SUM(o.TotalAmount) as total_spent
FROM customer c
LEFT JOIN orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING total_orders > 0
ORDER BY total_spent DESC
LIMIT 20;

-- ============================================================================
-- SECTION 2: OPERATIONS THAT SHOULD FAIL (RESTRICTED)
-- ============================================================================

-- Test 7: Attempt to insert a new order
-- Expected: FAIL - Sales Manager does NOT have INSERT privilege on orders
INSERT INTO orders (CustomerID, OrderDate, TotalAmount, OrderStatus)
VALUES (1, NOW(), 150.00, 'Pending');

-- Test 8: Attempt to delete an order
-- Expected: FAIL - Sales Manager does NOT have DELETE privilege on orders
DELETE FROM orders 
WHERE OrderID = 999;

-- Test 9: Attempt to update customer information
-- Expected: FAIL - Sales Manager has only SELECT on customer, not UPDATE
UPDATE customer 
SET Email = 'newemail@example.com' 
WHERE CustomerID = 1;

-- Test 10: Attempt to view delivery information
-- Expected: FAIL - Sales Manager does NOT have access to delivery table
SELECT * FROM delivery 
WHERE OrderID = 1;

-- Test 11: Attempt to modify product prices
-- Expected: FAIL - Sales Manager has only SELECT on product, not UPDATE
UPDATE product 
SET ProductName = 'Updated Product' 
WHERE ProductID = 1;

-- Test 12: Attempt to access supplier information
-- Expected: FAIL - Sales Manager does NOT have access to supplier table
SELECT * FROM supplier 
WHERE SupplierID = 1;

-- Test 13: Attempt to view discount information
-- Expected: FAIL - Sales Manager does NOT have access to discount table
SELECT * FROM discount 
WHERE DiscountPercentage > 10;

-- Test 14: Attempt to insert a payment record
-- Expected: FAIL - Sales Manager has only SELECT on payment, not INSERT
INSERT INTO payment (OrderID, StatementDate, Amount, PaymentMethod, PaymentStatus)
VALUES (1, NOW(), 100.00, 'Credit Card', 'Completed');

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check current user privileges
SHOW GRANTS FOR CURRENT_USER();

-- Verify connection user
SELECT USER(), CURRENT_USER(), DATABASE();

-- ============================================================================
-- END OF SALES MANAGER ROLE TEST FILE
-- ============================================================================
