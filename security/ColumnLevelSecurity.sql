USE ecommerce_db;

-- Customer service can update only specific columns
GRANT UPDATE(LoyaltyPoints, AccountStatus) ON ecommerce_db.customer TO 'customer_service'@'localhost';

-- Warehouse staff can update stock
GRANT UPDATE(StockStatus) ON ecommerce_db.product TO 'warehouse_staff'@'localhost';
