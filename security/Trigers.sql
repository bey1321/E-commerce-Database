USE ecommerce_db;

DELIMITER $$

-- =========================
-- CUSTOMER TRIGGERS
-- =========================
CREATE TRIGGER customer_insert_audit
AFTER INSERT ON customer
FOR EACH ROW
BEGIN
    INSERT INTO customer_audit (CustomerID, ActionType, NewFirstName, NewLastName, NewAccountStatus, NewLoyaltyPoints, ChangedBy)
    VALUES (NEW.CustomerID, 'INSERT', NEW.FirstName, NEW.LastName, NEW.AccountStatus, NEW.LoyaltyPoints, USER());
END$$

CREATE TRIGGER customer_update_audit
AFTER UPDATE ON customer
FOR EACH ROW
BEGIN
    INSERT INTO customer_audit (CustomerID, ActionType, OldFirstName, NewFirstName, OldLastName, NewLastName, OldAccountStatus, NewAccountStatus, OldLoyaltyPoints, NewLoyaltyPoints, ChangedBy)
    VALUES (OLD.CustomerID, 'UPDATE', OLD.FirstName, NEW.FirstName, OLD.LastName, NEW.LastName, OLD.AccountStatus, NEW.AccountStatus, OLD.LoyaltyPoints, NEW.LoyaltyPoints, USER());
END$$

CREATE TRIGGER customer_delete_audit
BEFORE DELETE ON customer
FOR EACH ROW
BEGIN
    INSERT INTO customer_audit (CustomerID, ActionType, OldFirstName, OldLastName, OldAccountStatus, OldLoyaltyPoints, ChangedBy)
    VALUES (OLD.CustomerID, 'DELETE', OLD.FirstName, OLD.LastName, OLD.AccountStatus, OLD.LoyaltyPoints, USER());
END$$

-- =========================
-- CARD TRIGGERS
-- =========================
CREATE TRIGGER card_insert_audit
AFTER INSERT ON card
FOR EACH ROW
BEGIN
    INSERT INTO card_audit (CardID, ActionType, NewCardNumber, NewExpiryYear, NewExpiryMonth, ChangedBy)
    VALUES (NEW.CardID, 'INSERT', NEW.CardNumber, NEW.ExpiryYear, NEW.ExpiryMonth, USER());
END$$

CREATE TRIGGER card_update_audit
AFTER UPDATE ON card
FOR EACH ROW
BEGIN
    INSERT INTO card_audit (CardID, ActionType, OldCardNumber, NewCardNumber, OldExpiryYear, NewExpiryYear, OldExpiryMonth, NewExpiryMonth, ChangedBy)
    VALUES (OLD.CardID, 'UPDATE', OLD.CardNumber, NEW.CardNumber, OLD.ExpiryYear, NEW.ExpiryYear, OLD.ExpiryMonth, NEW.ExpiryMonth, USER());
END$$

CREATE TRIGGER card_delete_audit
BEFORE DELETE ON card
FOR EACH ROW
BEGIN
    INSERT INTO card_audit (CardID, ActionType, OldCardNumber, OldExpiryYear, OldExpiryMonth, ChangedBy)
    VALUES (OLD.CardID, 'DELETE', OLD.CardNumber, OLD.ExpiryYear, OLD.ExpiryMonth, USER());
END$$

-- =========================
-- PRODUCT TRIGGERS
-- =========================
CREATE TRIGGER product_insert_audit
AFTER INSERT ON product
FOR EACH ROW
BEGIN
    INSERT INTO product_audit (ProductID, ActionType, NewProductName, NewStockStatus, ChangedBy)
    VALUES (NEW.ProductID, 'INSERT', NEW.ProductName, NEW.StockStatus, USER());
END$$

CREATE TRIGGER product_update_audit
AFTER UPDATE ON product
FOR EACH ROW
BEGIN
    INSERT INTO product_audit (ProductID, ActionType, OldProductName, NewProductName, OldStockStatus, NewStockStatus, ChangedBy)
    VALUES (OLD.ProductID, 'UPDATE', OLD.ProductName, NEW.ProductName, OLD.StockStatus, NEW.StockStatus, USER());
END$$

CREATE TRIGGER product_delete_audit
BEFORE DELETE ON product
FOR EACH ROW
BEGIN
    INSERT INTO product_audit (ProductID, ActionType, OldProductName, OldStockStatus, ChangedBy)
    VALUES (OLD.ProductID, 'DELETE', OLD.ProductName, OLD.StockStatus, USER());
END$$

-- =========================
-- ORDERS TRIGGERS
-- =========================
CREATE TRIGGER orders_insert_audit
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO orders_audit (OrderID, ActionType, NewOrderStatus, NewTotalAmount, ChangedBy)
    VALUES (NEW.OrderID, 'INSERT', NEW.OrderStatus, NEW.TotalAmount, USER());
END$$

CREATE TRIGGER orders_update_audit
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO orders_audit (OrderID, ActionType, OldOrderStatus, NewOrderStatus, OldTotalAmount, NewTotalAmount, ChangedBy)
    VALUES (OLD.OrderID, 'UPDATE', OLD.OrderStatus, NEW.OrderStatus, OLD.TotalAmount, NEW.TotalAmount, USER());
END$$

CREATE TRIGGER orders_delete_audit
BEFORE DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO orders_audit (OrderID, ActionType, OldOrderStatus, OldTotalAmount, ChangedBy)
    VALUES (OLD.OrderID, 'DELETE', OLD.OrderStatus, OLD.TotalAmount, USER());
END$$

-- =========================
-- PAYMENT TRIGGERS
-- =========================
CREATE TRIGGER payment_insert_audit
AFTER INSERT ON payment
FOR EACH ROW
BEGIN
    INSERT INTO payment_audit (PaymentID, ActionType, NewAmount, NewPaymentStatus, ChangedBy)
    VALUES (NEW.PaymentID, 'INSERT', NEW.Amount, NEW.PaymentStatus, USER());
END$$

CREATE TRIGGER payment_update_audit
AFTER UPDATE ON payment
FOR EACH ROW
BEGIN
    INSERT INTO payment_audit (PaymentID, ActionType, OldAmount, NewAmount, OldPaymentStatus, NewPaymentStatus, ChangedBy)
    VALUES (OLD.PaymentID, 'UPDATE', OLD.Amount, NEW.Amount, OLD.PaymentStatus, NEW.PaymentStatus, USER());
END$$

CREATE TRIGGER payment_delete_audit
BEFORE DELETE ON payment
FOR EACH ROW
BEGIN
    INSERT INTO payment_audit (PaymentID, ActionType, OldAmount, OldPaymentStatus, ChangedBy)
    VALUES (OLD.PaymentID, 'DELETE', OLD.Amount, OLD.PaymentStatus, USER());
END$$

DELIMITER ;
