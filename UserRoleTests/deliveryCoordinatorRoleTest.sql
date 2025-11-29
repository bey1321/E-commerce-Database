-- ============================================================================
-- DELIVERY COORDINATOR ROLE TEST FILE
-- ============================================================================
-- Purpose: Test the privileges and restrictions of the Delivery Coordinator role
-- 
-- Granted Privileges:
-- - SELECT and UPDATE on: delivery
-- - SELECT on: deliveryPerson, orders, customer, address, customerAddress
-- - SELECT on: ActiveDeliveryView
--
-- Expected Behavior:
-- - Can view and update delivery status and assignments
-- - Can view delivery personnel, customer addresses, and order information
-- - Can access active delivery tracking through view
-- - Cannot modify customer, order, or address information
-- - Cannot access financial, product, or warehouse data
-- ============================================================================

-- Before running these tests, connect as Delivery Coordinator:
-- mysql -u DeliveryCoordinator -p ecommerce_db

USE ecommerce_db;

-- ============================================================================
-- SECTION 1: OPERATIONS THAT SHOULD WORK (ALLOWED)
-- ============================================================================

-- Test 1: View all deliveries with status
-- Expected: SUCCESS - Delivery Coordinator has SELECT on delivery table
SELECT DeliveryID, OrderID, DeliveryPersonID, 
       DeliveryDate, DeliveryStatus, TrackingID,
       DeliveryTimeEstimate, DeliveryDate
FROM delivery 
WHERE DeliveryDate >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
ORDER BY DeliveryDate DESC;

-- Test 2: Update delivery status (key responsibility)
-- Expected: SUCCESS - Delivery Coordinator has UPDATE on delivery table
UPDATE delivery 
SET DeliveryStatus = 'In Transit'
WHERE DeliveryID = 1 AND DeliveryStatus = 'Pending';

-- Test 3: Assign delivery to a delivery person
-- Expected: SUCCESS - Delivery Coordinator has UPDATE on delivery table
UPDATE delivery 
SET DeliveryPersonID = 2,
    DeliveryStatus = 'Assigned'
WHERE DeliveryID = 3 AND DeliveryStatus = 'Pending';

-- Test 4: Update actual delivery time
-- Expected: SUCCESS - Delivery Coordinator has UPDATE on delivery table
UPDATE delivery 
SET DeliveryStatus = 'Delivered',
    DeliveryDate = NOW()
WHERE DeliveryID = 5 AND DeliveryStatus = 'In Transit';

-- Test 5: View delivery personnel roster
-- Expected: SUCCESS - Delivery Coordinator has SELECT on deliveryPerson table
SELECT DeliveryPersonID, DeliveryPersonName
FROM deliveryPerson 
ORDER BY DeliveryPersonID;

-- Test 6: View order information for deliveries
-- Expected: SUCCESS - Delivery Coordinator has SELECT on orders table
SELECT o.OrderID, o.CustomerID, o.OrderDate, o.TotalAmount, o.OrderStatus,
       d.DeliveryID, d.DeliveryStatus, o.TrackingID
FROM orders o
LEFT JOIN delivery d ON o.OrderID = d.OrderID
WHERE o.OrderStatus IN ('Processing', 'Shipped')
ORDER BY o.OrderDate DESC;

-- Test 7: View customer delivery addresses
-- Expected: SUCCESS - Delivery Coordinator has SELECT on customer, address, customerAddress
SELECT c.CustomerID, c.FirstName, c.LastName,
       a.AddressID, a.Street, a.City, a.State, a.PostalCode,
       ca.AddressType, ca.IsPrimary
FROM customer c
JOIN customerAddress ca ON c.CustomerID = ca.CustomerID
JOIN address a ON ca.AddressID = a.AddressID
WHERE ca.IsPrimary = TRUE;

-- Test 8: View active deliveries through view
-- Expected: SUCCESS - Delivery Coordinator has SELECT on ActiveDeliveryView
SELECT DeliveryID, OrderID, CustomerName, DeliveryAddress,
       DeliveryPersonName, DeliveryStatus, TrackingID,
       EstimatedDeliveryTime
FROM ActiveDeliveryView
WHERE DeliveryStatus IN ('Pending', 'Assigned', 'In Transit')
ORDER BY EstimatedDeliveryTime ASC;

-- Test 9: Route planning - deliveries by delivery person
-- Expected: SUCCESS - Complex query using allowed tables
SELECT dp.DeliveryPersonID, dp.DeliveryPersonName,
       COUNT(d.DeliveryID) as assigned_deliveries,
       GROUP_CONCAT(o.TrackingID) as tracking_numbers
FROM deliveryPerson dp
LEFT JOIN delivery d ON dp.DeliveryPersonID = d.DeliveryPersonID
LEFT JOIN orders o ON d.OrderID = o.OrderID
WHERE d.DeliveryStatus IN ('Assigned', 'In Transit')
GROUP BY dp.DeliveryPersonID, dp.DeliveryPersonName
ORDER BY assigned_deliveries DESC;

-- Test 10: Deliveries by city for route optimization
-- Expected: SUCCESS - Joining allowed tables
SELECT a.City, a.State,
       COUNT(d.DeliveryID) as pending_deliveries,
       MIN(d.DeliveryTimeEstimate) as earliest_delivery
FROM delivery d
JOIN orders o ON d.OrderID = o.OrderID
JOIN customer c ON o.CustomerID = c.CustomerID
JOIN customerAddress ca ON c.CustomerID = ca.CustomerID AND ca.IsPrimary = TRUE
JOIN address a ON ca.AddressID = a.AddressID
WHERE d.DeliveryStatus IN ('Pending', 'Assigned')
GROUP BY a.City, a.State
ORDER BY pending_deliveries DESC;

-- ============================================================================
-- SECTION 2: OPERATIONS THAT SHOULD FAIL (RESTRICTED)
-- ============================================================================

-- Test 11: Attempt to insert a new delivery
-- Expected: FAIL - Delivery Coordinator has only SELECT and UPDATE on delivery, not INSERT
INSERT INTO delivery (OrderID, DeliveryPersonID, DeliveryDate, DeliveryStatus)
VALUES (10, 1, CURDATE(), 'Pending');

-- Test 12: Attempt to delete a delivery record
-- Expected: FAIL - Delivery Coordinator does NOT have DELETE privilege on delivery
DELETE FROM delivery 
WHERE DeliveryID = 999;

-- Test 13: Attempt to modify customer information
-- Expected: FAIL - Delivery Coordinator has only SELECT on customer, not UPDATE
UPDATE customer 
SET Email = 'newemail@example.com'
WHERE CustomerID = 1;

-- Test 14: Attempt to update order status
-- Expected: FAIL - Delivery Coordinator has only SELECT on orders, not UPDATE
UPDATE orders 
SET OrderStatus = 'Delivered',
    TotalAmount = 250.00
WHERE OrderID = 1;

-- Test 15: Attempt to modify address information
-- Expected: FAIL - Delivery Coordinator has only SELECT on address, not UPDATE
UPDATE address 
SET Street = '123 New Street',
    City = 'New City'
WHERE AddressID = 1;

-- Test 16: Attempt to update delivery person information
-- Expected: FAIL - Delivery Coordinator has only SELECT on deliveryPerson, not UPDATE
UPDATE deliveryPerson 
SET DeliveryPersonName = 'Updated Name'
WHERE DeliveryPersonID = 1;

-- Test 17: Attempt to view payment information
-- Expected: FAIL - Delivery Coordinator does NOT have access to payment table
SELECT * FROM payment 
WHERE OrderID = 1;

-- Test 18: Attempt to view product information
-- Expected: FAIL - Delivery Coordinator does NOT have access to product table
SELECT * FROM product 
WHERE ProductID = 1;

-- Test 19: Attempt to view supplier information
-- Expected: FAIL - Delivery Coordinator does NOT have access to supplier table
SELECT * FROM supplier;

-- Test 20: Attempt to view discount information
-- Expected: FAIL - Delivery Coordinator does NOT have access to discount table
SELECT * FROM discount;

-- Test 21: Attempt to insert a new delivery person
-- Expected: FAIL - Delivery Coordinator has only SELECT on deliveryPerson, not INSERT
INSERT INTO deliveryPerson (DeliveryPersonName)
VALUES ('John Doe');

-- Test 22: Attempt to view return information
-- Expected: FAIL - Delivery Coordinator does NOT have access to returnTable
SELECT * FROM returnTable;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check current user privileges
SHOW GRANTS FOR CURRENT_USER();

-- Verify connection user
SELECT USER(), CURRENT_USER(), DATABASE();

-- Delivery status summary
SELECT DeliveryStatus, COUNT(*) as count
FROM delivery
WHERE DeliveryDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DeliveryStatus
ORDER BY count DESC;

-- Available delivery personnel count
SELECT COUNT(*) as personnel_count
FROM deliveryPerson;

-- ============================================================================
-- END OF DELIVERY COORDINATOR ROLE TEST FILE
-- ============================================================================
