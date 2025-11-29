/*****************************************************************************************
UPDATE 1: Update a customer's first and last name
******************************************************************************************/
UPDATE customer
SET FirstName = 'Bethel', LastName = 'Habte'
WHERE CustomerID = 1;


/*****************************************************************************************
UPDATE 2: Change the stock status of a product
******************************************************************************************/
UPDATE product
SET StockStatus = 'Low Stock'
WHERE ProductID = 5;


/*****************************************************************************************
UPDATE 3: Update the price a supplier sells a product for
******************************************************************************************/
UPDATE supplierProduct
SET SellingPrice = 150.00
WHERE SupplierID = 2 AND ProductID = 10;


/*****************************************************************************************
UPDATE 4: Update the quantity of a product in a supplier's inventory
******************************************************************************************/
UPDATE supplierProduct
SET Quantity = 50
WHERE SupplierID = 3 AND ProductID = 8;


/*****************************************************************************************
UPDATE 5: Update the email of a customer (using customerEmail table)
******************************************************************************************/
UPDATE customerEmail
SET CustomerEmail = 'newemail@example.com'
WHERE CustomerID = 1 AND CustomerEmail = 'oldemail@example.com';


/*****************************************************************************************
UPDATE 6: Update the shipping fee of an order
******************************************************************************************/
UPDATE orders
SET ShippingFee = 25.50
WHERE OrderID = 12;


/*****************************************************************************************
UPDATE 7: Update a customer's loyalty points
******************************************************************************************/
UPDATE customer
SET LoyaltyPoints = LoyaltyPoints + 100
WHERE CustomerID = 4;


/*****************************************************************************************
UPDATE 8 (modified): Update the supplier price based on quantity
******************************************************************************************/
UPDATE supplierProduct
SET SupplierPrice = CASE
    WHEN Quantity > 50 THEN SupplierPrice * 1.05  -- increase by 5% if stock is high
    ELSE SupplierPrice * 1.10                     -- increase by 10% if stock is low
END
WHERE ProductID = 7;



/*****************************************************************************************
UPDATE 9: Update the discount value in a discount table
******************************************************************************************/
UPDATE discount
SET DiscountValue = 20.00, IsPercentage = 1
WHERE DiscountID = 3;


/*****************************************************************************************
UPDATE 10: Update the tracking ID of an order
******************************************************************************************/
UPDATE orders
SET TrackingID = 'TRACK123456789'
WHERE OrderID = 15;
