-- =========================================
-- AUDIT TABLES FOR E-COMMERCE DATABASE
-- =========================================

USE ecommerce_db;

-- 1. Customer Audit
CREATE TABLE customer_audit (
    AuditID          INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID       INT NOT NULL,
    ActionType       VARCHAR(20) NOT NULL CHECK(ActionType IN ('INSERT','UPDATE','DELETE')),
    OldFirstName     VARCHAR(50),
    NewFirstName     VARCHAR(50),
    OldLastName      VARCHAR(50),
    NewLastName      VARCHAR(50),
    OldAccountStatus VARCHAR(20),
    NewAccountStatus VARCHAR(20),
    OldLoyaltyPoints INT,
    NewLoyaltyPoints INT,
    ChangedBy        VARCHAR(50),
    ChangeTimestamp  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Card Audit
CREATE TABLE card_audit (
    AuditID        INT AUTO_INCREMENT PRIMARY KEY,
    CardID         INT NOT NULL,
    ActionType     VARCHAR(20) NOT NULL CHECK(ActionType IN ('INSERT','UPDATE','DELETE')),
    OldCardNumber  VARCHAR(20),
    NewCardNumber  VARCHAR(20),
    OldExpiryYear  INT,
    NewExpiryYear  INT,
    OldExpiryMonth INT,
    NewExpiryMonth INT,
    ChangedBy      VARCHAR(50),
    ChangeTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 3. Product Audit
CREATE TABLE product_audit (
    AuditID       INT AUTO_INCREMENT PRIMARY KEY,
    ProductID     INT NOT NULL,
    ActionType    VARCHAR(20) NOT NULL CHECK(ActionType IN ('INSERT','UPDATE','DELETE')),
    OldProductName VARCHAR(100),
    NewProductName VARCHAR(100),
    OldStockStatus VARCHAR(20),
    NewStockStatus VARCHAR(20),
    ChangedBy     VARCHAR(50),
    ChangeTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 4. Orders Audit
CREATE TABLE orders_audit (
    AuditID        INT AUTO_INCREMENT PRIMARY KEY,
    OrderID        INT NOT NULL,
    ActionType     VARCHAR(20) NOT NULL CHECK(ActionType IN ('INSERT','UPDATE','DELETE')),
    OldOrderStatus VARCHAR(20),
    NewOrderStatus VARCHAR(20),
    OldTotalAmount DECIMAL(10,2),
    NewTotalAmount DECIMAL(10,2),
    ChangedBy      VARCHAR(50),
    ChangeTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 5. Payment Audit
CREATE TABLE payment_audit (
    AuditID         INT AUTO_INCREMENT PRIMARY KEY,
    PaymentID       INT NOT NULL,
    ActionType      VARCHAR(20) NOT NULL CHECK(ActionType IN ('INSERT','UPDATE','DELETE')),
    OldAmount       DECIMAL(10,2),
    NewAmount       DECIMAL(10,2),
    OldPaymentStatus VARCHAR(20),
    NewPaymentStatus VARCHAR(20),
    ChangedBy       VARCHAR(50),
    ChangeTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
