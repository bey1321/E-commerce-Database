USE ecommerce_db;

-- Customer Service View
CREATE VIEW CustomerServiceView AS
SELECT 
    CustomerID, FirstName, LastName, RegistrationDate, LoyaltyPoints, AccountStatus
FROM customer;

-- Order Summary View for Sales Managers
CREATE VIEW OrderSummaryView AS
SELECT OrderID, OrderDate, TotalAmount, ShippingFee, OrderStatus, CustomerID
FROM orders;

-- Product Inventory View for Warehouse Staff
CREATE VIEW ProductInventoryView AS
SELECT p.ProductID, p.ProductName, p.SKU, p.Weight, p.Dimensions, p.StockStatus, pa.SalesCount, pa.LastMonthSales
FROM product p
LEFT JOIN productAnalytics pa ON p.ProductID = pa.ProductID;

-- Active Delivery View for Delivery Coordinators
CREATE VIEW ActiveDeliveryView AS
SELECT d.DeliveryID, d.DeliveryDate, d.DeliveryStatus, d.DeliveryFee, o.OrderID, o.TrackingID, a.Street, a.City
FROM delivery d
JOIN orders o ON d.OrderID = o.OrderID
JOIN address a ON d.AddressID = a.AddressID
WHERE d.DeliveryStatus IN ('Pending', 'In Transit', 'Out for Delivery');

-- Marketing Analytics View
CREATE VIEW MarketingAnalyticsView AS
SELECT p.ProductID, p.ProductName, pa.SalesCount, pa.LastMonthSales, pa.IsBestSeller, pa.IsNewRelease,
       AVG(r.RatingValue) AS AverageRating, COUNT(r.RatingID) AS TotalReviews
FROM product p
LEFT JOIN productAnalytics pa ON p.ProductID = pa.ProductID
LEFT JOIN rating r ON p.ProductID = r.ProductID
GROUP BY p.ProductID;

/*****************************************************************************************
VIEW: ReturnManagementView
--------------------------------
Purpose:
- Shows all returns, their associated orders, customers, products, and payment info.
- Useful for return processing, refund tracking, and customer service.
******************************************************************************************/

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

/*****************************************************************************************
VIEW: ActiveDeliveryView
--------------------------------
Purpose:
- Displays all ongoing deliveries with customer and delivery person information.
- Useful for logistics, delivery tracking, and operational dashboards.
******************************************************************************************/

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
    c.FirstName || ' ' || c.LastName AS CustomerName,
    dp.DeliveryPersonID,
    dp.DeliveryPersonName
FROM delivery d
JOIN orders o ON d.OrderID = o.OrderID
JOIN customer c ON o.CustomerID = c.CustomerID
LEFT JOIN deliveryPerson dp ON d.DeliveryPersonID = dp.DeliveryPersonID
WHERE d.DeliveryStatus IN ('Pending', 'In Transit', 'Out for Delivery');


CREATE VIEW MaskedPaymentView AS
SELECT
    p.PaymentID,
    p.OrderID,
    p.StatementDate,
    p.Amount,
    p.PaymentMethod,
    p.PaymentStatus,
    CONCAT('****-****-****-', RIGHT(c.CardNumber, 4)) AS MaskedCardNumber,
    CONCAT(c.ExpiryMonth, '/', c.ExpiryYear) AS Expiry
FROM payment p
LEFT JOIN card c ON p.CardID = c.CardID;