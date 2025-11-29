-- MySQL Delete Statements for E-commerce Database
USE ecommerce_db;

/*****************************************************************************************
DELETE 1: Delete a specific customer's profile picture
******************************************************************************************/
DELETE FROM profilePictureURL
WHERE CustomerID = 5;


/*****************************************************************************************
DELETE 2: Delete a product from a customer's wishlist
******************************************************************************************/
DELETE FROM wishListProduct
WHERE WishListID = 3 AND ProductID = 1;


/*****************************************************************************************
DELETE 3: Delete an abandoned cart
******************************************************************************************/
-- Delete cart-order relationship first
DELETE FROM orderCart
WHERE CartID = 5;

-- Delete cart products
DELETE FROM cartProduct
WHERE CartID = 5;

-- Delete cart discounts
DELETE FROM cartDiscount
WHERE CartID = 5;

-- Finally delete the cart itself
DELETE FROM cart
WHERE CartID = 5 AND CartStatus = 'Abandoned';


/*****************************************************************************************
DELETE 4: Delete a promo code that has expired
******************************************************************************************/
DELETE FROM promoCode
WHERE PromoCodeID = 1 AND Status = 'Expired';


/*****************************************************************************************
DELETE 5: Delete a customer's old phone number
******************************************************************************************/
DELETE FROM customerContact
WHERE CustomerID = 2 AND PhoneNumber = '+1-555-0102';


/*****************************************************************************************
DELETE 6: Delete a product image URL
******************************************************************************************/
DELETE FROM productImageURL
WHERE ProductID = 3 AND ImageURL = 'https://example.com/products/cable1.jpg';


/*****************************************************************************************
DELETE 7: Delete a discount that is no longer applicable
******************************************************************************************/
DELETE FROM productDiscount
WHERE DiscountID = 6;

DELETE FROM cartDiscount
WHERE DiscountID = 6;

DELETE FROM orderDiscount
WHERE DiscountID = 6;

DELETE FROM customerDiscount
WHERE DiscountID = 6;

DELETE FROM promoCode
WHERE DiscountID = 6;

DELETE FROM maxOrderDiscount
WHERE DiscountID = 6;

DELETE FROM maxCartDiscount
WHERE DiscountID = 6;

DELETE FROM discount
WHERE DiscountID = 6;


/*****************************************************************************************
DELETE 8: Delete a supplier's contact information
******************************************************************************************/
DELETE FROM supplierContact
WHERE SupplierID = 7 AND PhoneNumber = '+1-800-555-0007';


/*****************************************************************************************
DELETE 9: Delete a completed return request
******************************************************************************************/
DELETE FROM returnTable
WHERE ReturnID = 8 AND ReturnStatus = 'Completed';


/*****************************************************************************************
DELETE 10: Delete a customer card that has expired
******************************************************************************************/
-- First, delete returns that reference payments with expired cards
DELETE FROM returnTable
WHERE PaymentID IN (
    SELECT PaymentID FROM (
        SELECT PaymentID FROM payment 
        WHERE CardID IN (
            SELECT CardID FROM card 
            WHERE (ExpiryYear < 2025) OR (ExpiryYear = 2025 AND ExpiryMonth < 11)
        )
    ) AS expired_payments
);

-- Then delete payments that reference the expired cards
DELETE FROM payment
WHERE CardID IN (
    SELECT CardID FROM (
        SELECT CardID FROM card 
        WHERE (ExpiryYear < 2025) OR (ExpiryYear = 2025 AND ExpiryMonth < 11)
    ) AS expired_cards
);

-- Then delete from customerCard
DELETE FROM customerCard
WHERE CardID IN (
    SELECT CardID FROM (
        SELECT CardID FROM card 
        WHERE (ExpiryYear < 2025) OR (ExpiryYear = 2025 AND ExpiryMonth < 11)
    ) AS expired_cards
);

-- Finally delete the card itself
DELETE FROM card
WHERE CardID IN (
    SELECT CardID FROM (
        SELECT CardID FROM card 
        WHERE (ExpiryYear < 2025) OR (ExpiryYear = 2025 AND ExpiryMonth < 11)
    ) AS expired_cards
);


/*****************************************************************************************
DELETE 11: Delete products that are discontinued and out of stock
******************************************************************************************/
DELETE FROM productImageURL
WHERE ProductID IN (SELECT ProductID FROM product WHERE StockStatus = 'Discontinued');

DELETE FROM productCategory
WHERE ProductID IN (SELECT ProductID FROM product WHERE StockStatus = 'Discontinued');

DELETE FROM productAnalytics
WHERE ProductID IN (SELECT ProductID FROM product WHERE StockStatus = 'Discontinued');

DELETE FROM productDiscount
WHERE ProductID IN (SELECT ProductID FROM product WHERE StockStatus = 'Discontinued');

-- Note: Cannot delete products if they have existing orders, ratings, or other dependencies


/*****************************************************************************************
DELETE 12: Delete a delivery person's email
******************************************************************************************/
DELETE FROM deliveryPersonEmail
WHERE DeliveryPersonID = 4 AND DeliveryPersonEmail = 'olivia.t@delivery.com';


/*****************************************************************************************
DELETE 13: Delete customer address type
******************************************************************************************/
DELETE FROM customerAddressType
WHERE AddressID = 9 AND AddressType = 'Shipping';


/*****************************************************************************************
DELETE 14: Delete supplier address type
******************************************************************************************/
DELETE FROM supplierAddressType
WHERE AddressID = 7 AND AddressType = 'Office';


/*****************************************************************************************
DELETE 15: Delete a gift card that has been fully redeemed
******************************************************************************************/
DELETE FROM orderGiftCard
WHERE GiftCardID IN (
    SELECT GiftCardID FROM (
        SELECT GiftCardID FROM giftCard 
        WHERE CurrentBalance = 0 AND CardStatus = 'Redeemed'
    ) AS redeemed_cards
);

DELETE FROM giftCard
WHERE GiftCardID IN (
    SELECT GiftCardID FROM (
        SELECT GiftCardID FROM giftCard 
        WHERE CurrentBalance = 0 AND CardStatus = 'Redeemed'
    ) AS redeemed_cards
);
