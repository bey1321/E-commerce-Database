-- ============================================================================
-- WAREHOUSE STAFF ROLE TEST FILE
-- ============================================================================
-- Purpose: Test the privileges and restrictions of the Warehouse Staff role
-- 
-- Granted Privileges:
-- - SELECT and UPDATE on: product
-- - SELECT, INSERT, and UPDATE on: supplierProduct
-- - SELECT on: supplier, productAnalytics
--
-- Expected Behavior:
-- - Can view and update product inventory levels
-- - Can manage supplier-product relationships (add and update)
-- - Can view supplier information and product analytics
-- - Cannot access customer data, orders, or financial information
-- - Cannot delete records
-- ============================================================================

-- Before running these tests, connect as Warehouse Staff:
-- mysql -u WarehouseStaff -p ecommerce_db

USE ecommerce_db;

-- ============================================================================
-- SECTION 1: OPERATIONS THAT SHOULD WORK (ALLOWED)
-- ============================================================================

-- Test 1: View product inventory
-- Expected: SUCCESS - Warehouse Staff has SELECT on product table
SELECT ProductID, ProductName, StockStatus, 
       Dimensions, Weight
FROM product 
ORDER BY ProductID ASC
LIMIT 20;

-- Test 2: Update product stock quantity (key responsibility)
-- Expected: SUCCESS - Warehouse Staff has UPDATE on product table
UPDATE product 
SET Dimensions = 'Updated Dimensions'
WHERE ProductID = 1;

-- Test 3: Update product warehouse location
-- Expected: SUCCESS - Warehouse Staff has UPDATE on product table
UPDATE product 
SET Weight = 10.5
WHERE ProductID = 2;

-- Test 4: View supplier information
-- Expected: SUCCESS - Warehouse Staff has SELECT on supplier table
SELECT SupplierID, SupplierName, ContactPerson, Email
FROM supplier 
ORDER BY SupplierName;

-- Test 5: View supplier-product relationships
-- Expected: SUCCESS - Warehouse Staff has SELECT on supplierProduct table
SELECT sp.SupplierID, sp.ProductID, sp.SupplierPrice, sp.SellingPrice,
       s.SupplierName, p.ProductName, p.StockStatus
FROM supplierProduct sp
JOIN supplier s ON sp.SupplierID = s.SupplierID
JOIN product p ON sp.ProductID = p.ProductID
ORDER BY p.StockStatus ASC;

-- Test 6: Add new supplier-product relationship (key responsibility)
-- Expected: SUCCESS - Warehouse Staff has INSERT on supplierProduct table
INSERT INTO supplierProduct (SupplierID, ProductID, SupplierPrice, SellingPrice)
VALUES (1, 5, 25.50, 35.00);

-- Test 7: Update supplier pricing
-- Expected: SUCCESS - Warehouse Staff has UPDATE on supplierProduct table
UPDATE supplierProduct 
SET SupplierPrice = 28.00,
    SellingPrice = 38.00
WHERE SupplierID = 1 AND ProductID = 2;

-- Test 8: View product analytics for inventory planning
-- Expected: SUCCESS - Warehouse Staff has SELECT on productAnalytics table
SELECT pa.ProductID, p.ProductName, 
       pa.TotalSold, pa.TotalRevenue,
       pa.AverageRating,
       p.StockStatus
FROM productAnalytics pa
JOIN product p ON pa.ProductID = p.ProductID
WHERE p.StockStatus = 'Low Stock';

-- Test 9: Check low stock products with supplier information
-- Expected: SUCCESS - Complex query using allowed tables
SELECT p.ProductID, p.ProductName, p.StockStatus,
       s.SupplierName, s.ContactPerson,
       sp.SupplierPrice, sp.SellingPrice
FROM product p
LEFT JOIN supplierProduct sp ON p.ProductID = sp.ProductID
LEFT JOIN supplier s ON sp.SupplierID = s.SupplierID
WHERE p.StockStatus = 'Low Stock'
ORDER BY p.ProductID ASC;

-- ============================================================================
-- SECTION 2: OPERATIONS THAT SHOULD FAIL (RESTRICTED)
-- ============================================================================

-- Test 10: Attempt to delete a product
-- Expected: FAIL - Warehouse Staff does NOT have DELETE privilege on product
DELETE FROM product 
WHERE ProductID = 999;

-- Test 11: Attempt to insert a new product
-- Expected: FAIL - Warehouse Staff has only SELECT and UPDATE on product, not INSERT
INSERT INTO product (ProductName, Weight, StockStatus)
VALUES ('New Product', 5.5, 'In Stock');

-- Test 12: Attempt to view customer information
-- Expected: FAIL - Warehouse Staff does NOT have access to customer table
SELECT * FROM customer 
WHERE CustomerID = 1;

-- Test 13: Attempt to view order information
-- Expected: FAIL - Warehouse Staff does NOT have access to orders table
SELECT * FROM orders 
WHERE OrderDate >= DATE_SUB(CURDATE(), INTERVAL 7 DAY);

-- Test 14: Attempt to view payment information
-- Expected: FAIL - Warehouse Staff does NOT have access to payment table
SELECT * FROM payment 
WHERE PaymentMethod = 'Credit Card';

-- Test 15: Attempt to update supplier information
-- Expected: FAIL - Warehouse Staff has only SELECT on supplier, not UPDATE
UPDATE supplier 
SET Email = 'newemail@supplier.com'
WHERE SupplierID = 1;

-- Test 16: Attempt to delete supplier-product relationship
-- Expected: FAIL - Warehouse Staff does NOT have DELETE privilege on supplierProduct
DELETE FROM supplierProduct 
WHERE SupplierID = 1 AND ProductID = 1;

-- Test 17: Attempt to view return information
-- Expected: FAIL - Warehouse Staff does NOT have access to returnTable
SELECT * FROM returnTable;

-- Test 18: Attempt to view delivery information
-- Expected: FAIL - Warehouse Staff does NOT have access to delivery table
SELECT * FROM delivery;

-- Test 19: Attempt to modify product analytics
-- Expected: FAIL - Warehouse Staff has only SELECT on productAnalytics, not UPDATE
UPDATE productAnalytics 
SET TotalSold = 1000 
WHERE ProductID = 1;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check current user privileges
SHOW GRANTS FOR CURRENT_USER();

-- Verify connection user
SELECT USER(), CURRENT_USER(), DATABASE();

-- Inventory summary report
SELECT 
    COUNT(*) as total_products,
    COUNT(CASE WHEN StockStatus = 'In Stock' THEN 1 END) as in_stock_count,
    COUNT(CASE WHEN StockStatus = 'Low Stock' THEN 1 END) as low_stock_count
FROM product;

-- ============================================================================
-- END OF WAREHOUSE STAFF ROLE TEST FILE
-- ============================================================================
