-- ============================================================================
-- MARKETING TEAM ROLE TEST FILE
-- ============================================================================
-- Purpose: Test the privileges and restrictions of the Marketing Team role
-- 
-- Granted Privileges:
-- - SELECT on: product, productAnalytics, customer, orders, discount
-- - SELECT on: MarketingAnalyticsView
--
-- Expected Behavior:
-- - Can view all product and customer data for analysis
-- - Can access analytics data for campaign planning
-- - Can view discount and promotional information
-- - Cannot modify any data (read-only access)
-- - Cannot access operational tables (delivery, supplier, returns)
-- ============================================================================

-- Before running these tests, connect as Marketing Team:
-- mysql -u MarketingTeam -p ecommerce_db

USE ecommerce_db;

-- ============================================================================
-- SECTION 1: OPERATIONS THAT SHOULD WORK (ALLOWED)
-- ============================================================================

-- Test 1: View product catalog for marketing campaigns
-- Expected: SUCCESS - Marketing Team has SELECT on product table
SELECT ProductID, ProductName, Weight, Dimensions, 
       Warranty, StockStatus
FROM product 
WHERE StockStatus = 'In Stock'
ORDER BY ProductID DESC;

-- Test 2: View product performance analytics
-- Expected: SUCCESS - Marketing Team has SELECT on productAnalytics table
SELECT ProductID, TotalSold, TotalRevenue, 
       AverageRating, LastUpdated
FROM productAnalytics
ORDER BY TotalRevenue DESC
LIMIT 20;

-- Test 3: View customer demographics for targeting
-- Expected: SUCCESS - Marketing Team has SELECT on customer table
SELECT CustomerID, FirstName, LastName, Email,
       RegistrationDate, AccountStatus, LoyaltyPoints
FROM customer 
WHERE AccountStatus = 'Active'
ORDER BY LoyaltyPoints DESC
LIMIT 50;

-- Test 4: Analyze order patterns by date
-- Expected: SUCCESS - Marketing Team has SELECT on orders table
SELECT DATE(OrderDate) as order_day,
       COUNT(*) as order_count,
       SUM(TotalAmount) as daily_revenue,
       AVG(TotalAmount) as avg_order_value
FROM orders
WHERE OrderDate >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
GROUP BY DATE(OrderDate)
ORDER BY order_day DESC;

-- Test 5: View active discounts and promotions
-- Expected: SUCCESS - Marketing Team has SELECT on discount table
SELECT DiscountID, DiscountCode, DiscountPercentage, 
       StartDate, EndDate, MinimumPurchase
FROM discount
WHERE StartDate <= CURDATE() 
  AND EndDate >= CURDATE()
ORDER BY DiscountPercentage DESC;

-- Test 6: View marketing analytics dashboard data
-- Expected: SUCCESS - Marketing Team has SELECT on MarketingAnalyticsView
SELECT CustomerID, CustomerName, TotalOrders, TotalSpent,
       AverageOrderValue, LastOrderDate, CustomerSegment
FROM MarketingAnalyticsView
ORDER BY TotalSpent DESC
LIMIT 100;

-- Test 7: Customer segmentation analysis
-- Expected: SUCCESS - Complex query using allowed tables
SELECT 
    CASE 
        WHEN LoyaltyPoints >= 1000 THEN 'High Value'
        WHEN LoyaltyPoints >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END as customer_segment,
    COUNT(*) as customer_count,
    AVG(LoyaltyPoints) as avg_loyalty_points
FROM customer
GROUP BY customer_segment
ORDER BY avg_loyalty_points DESC;

-- Test 8: Product category performance
-- Expected: SUCCESS - Joining allowed tables for analysis
SELECT p.ProductID, p.ProductName,
       pa.TotalSold,
       pa.TotalRevenue,
       pa.AverageRating
FROM product p
LEFT JOIN productAnalytics pa ON p.ProductID = pa.ProductID
ORDER BY pa.TotalRevenue DESC;

-- Test 9: Customer acquisition analysis
-- Expected: SUCCESS - Marketing Team can analyze customer data
SELECT 
    DATE_FORMAT(RegistrationDate, '%Y-%m') as month,
    COUNT(*) as new_customers
FROM customer
WHERE RegistrationDate >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(RegistrationDate, '%Y-%m')
ORDER BY month DESC;

-- ============================================================================
-- SECTION 2: OPERATIONS THAT SHOULD FAIL (RESTRICTED)
-- ============================================================================

-- Test 10: Attempt to update product information
-- Expected: FAIL - Marketing Team has only SELECT on product, not UPDATE
UPDATE product 
SET Weight = 7.99, 
    Dimensions = '15x15x15'
WHERE ProductID = 1;

-- Test 11: Attempt to insert a new discount
-- Expected: FAIL - Marketing Team has only SELECT on discount, not INSERT
INSERT INTO discount (DiscountCode, DiscountPercentage, StartDate, EndDate)
VALUES ('SUMMER2025', 20, '2025-06-01', '2025-08-31');

-- Test 12: Attempt to delete a discount
-- Expected: FAIL - Marketing Team does NOT have DELETE privilege on discount
DELETE FROM discount 
WHERE DiscountID = 1;

-- Test 13: Attempt to modify customer information
-- Expected: FAIL - Marketing Team has only SELECT on customer, not UPDATE
UPDATE customer 
SET Email = 'marketing@example.com',
    AccountStatus = 'Premium'
WHERE CustomerID = 1;

-- Test 14: Attempt to update order information
-- Expected: FAIL - Marketing Team has only SELECT on orders, not UPDATE
UPDATE orders 
SET OrderStatus = 'Cancelled',
    TotalAmount = 0.00
WHERE OrderID = 1;

-- Test 15: Attempt to view payment details
-- Expected: FAIL - Marketing Team does NOT have access to payment table
SELECT * FROM payment 
WHERE PaymentMethod = 'Credit Card';

-- Test 16: Attempt to view supplier information
-- Expected: FAIL - Marketing Team does NOT have access to supplier table
SELECT * FROM supplier;

-- Test 17: Attempt to view return information
-- Expected: FAIL - Marketing Team does NOT have access to returnTable
SELECT * FROM returnTable 
WHERE ReturnStatus = 'Pending';

-- Test 18: Attempt to view delivery information
-- Expected: FAIL - Marketing Team does NOT have access to delivery table
SELECT * FROM delivery;

-- Test 19: Attempt to modify product analytics
-- Expected: FAIL - Marketing Team has only SELECT on productAnalytics, not UPDATE
UPDATE productAnalytics 
SET TotalSold = 5000,
    TotalRevenue = 50000.00
WHERE ProductID = 1;

-- Test 20: Attempt to insert new customer record
-- Expected: FAIL - Marketing Team has only SELECT on customer, not INSERT
INSERT INTO customer (FirstName, LastName, Email)
VALUES ('Test', 'Customer', 'test@example.com');

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check current user privileges
SHOW GRANTS FOR CURRENT_USER();

-- Verify connection user
SELECT USER(), CURRENT_USER(), DATABASE();

-- Quick marketing metrics summary
SELECT 
    (SELECT COUNT(*) FROM customer) as total_customers,
    (SELECT COUNT(*) FROM orders) as total_orders,
    (SELECT COUNT(*) FROM product) as total_products,
    (SELECT COUNT(*) FROM discount WHERE EndDate >= CURDATE()) as active_discounts;

-- ============================================================================
-- END OF MARKETING TEAM ROLE TEST FILE
-- ============================================================================
