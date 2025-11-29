/*****************************************************************************************
VIEW 1: vw_CustomerOrderSummary
--------------------------------
Purpose:
- Shows each customer's orders with basic order information.
******************************************************************************************/

CREATE VIEW vw_CustomerOrderSummary AS
SELECT
    c.CustomerID,
    c.FirstName || ' ' || c.LastName AS CustomerName,
    o.OrderID,
    o.OrderDate,
    o.TotalAmount,
    o.ShippingFee,
    o.TrackingID
FROM customer c
JOIN orders o ON c.CustomerID = o.CustomerID;


/* Create a table snapshot from the view */
CREATE TABLE CustomerOrderSummaryTable AS
SELECT * FROM vw_CustomerOrderSummary;




/*****************************************************************************************
VIEW 2: vw_OrderProductDetails
--------------------------------
Purpose:
- Shows what products were purchased in each order.
******************************************************************************************/

CREATE VIEW vw_OrderProductDetails AS
SELECT
    o.OrderID,
    o.OrderDate,
    p.ProductName,
    op.Quantity,
    op.PriceAtPurchase AS UnitPrice,
    (op.Quantity * op.PriceAtPurchase) AS SubTotal
FROM orders o
JOIN orderProduct op ON o.OrderID = op.OrderID
JOIN product p ON op.ProductID = p.ProductID;


/* Create a table snapshot from the view */
CREATE TABLE OrderProductDetailsTable AS
SELECT * FROM vw_OrderProductDetails;




/*****************************************************************************************
VIEW 3: vw_SupplierInventory
--------------------------------
Purpose:
- Shows which supplier provides which product and inventory details.
******************************************************************************************/

CREATE VIEW vw_SupplierInventory AS
SELECT
    s.SupplierID,
    s.SupplierName,
    p.ProductID,
    p.ProductName,
    sp.SupplierPrice,
    sp.SellingPrice,
    sp.Quantity,
    sp.DateAdded,
    sp.Description
FROM supplier s
JOIN supplierProduct sp ON s.SupplierID = sp.SupplierID
JOIN product p ON sp.ProductID = p.ProductID;


/* Create a table snapshot from the view */
CREATE TABLE SupplierInventoryTable AS
SELECT * FROM vw_SupplierInventory;




/*****************************************************************************************
VIEW 4: vw_CustomerWishlist
--------------------------------
Purpose:
- Displays products a customer added to their wishlist.
******************************************************************************************/

CREATE VIEW vw_CustomerWishlist AS
SELECT
    c.CustomerID,
    c.FirstName || ' ' || c.LastName AS CustomerName,
    p.ProductName,
    wlp.ProductID,
    wlp.DateAdded AS DateAddedToWishlist
FROM customer c
JOIN wishList w ON c.CustomerID = w.CustomerID
JOIN wishListProduct wlp ON w.WishListID = wlp.WishListID
JOIN product p ON wlp.ProductID = p.ProductID;


/* Create a table snapshot from the view */
CREATE TABLE CustomerWishlistTable AS
SELECT * FROM vw_CustomerWishlist;




/*****************************************************************************************
VIEW 5: vw_OrderPaymentStatus
--------------------------------
Purpose:
- Combines order, payment, and return details into one view.
******************************************************************************************/

CREATE VIEW vw_OrderPaymentStatus AS
SELECT
    o.OrderID,
    o.OrderDate,
    o.TotalAmount,
    /* Payment columns */
    p.Amount AS PaymentAmount,
    p.PaymentMethod,
    p.PaymentStatus,
    p.StatementDate,
    p.PaymentGateway,
    p.FailureReason,
    /* Return information */
    r.ReturnID,
    r.ReturnAmount,
    r.ReturnDate,
    r.ReturnStatus,
    r.Reason AS ReturnReason

FROM orders o
LEFT JOIN payment p ON o.OrderID = p.OrderID
LEFT JOIN returnTable r ON o.OrderID = r.OrderID;

CREATE TABLE OrderPaymentStatusTable AS
SELECT * FROM vw_OrderPaymentStatus;
