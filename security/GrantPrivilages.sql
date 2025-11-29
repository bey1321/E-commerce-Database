USE ecommerce_db;

-- Admin: Full Access
GRANT ALL PRIVILEGES ON ecommerce_db.* TO 'admin_user'@'localhost';

-- Sales Manager: Read and update orders, read customers
GRANT SELECT ON ecommerce_db.customer TO 'sales_manager'@'localhost';
GRANT SELECT, UPDATE ON ecommerce_db.orders TO 'sales_manager'@'localhost';
GRANT SELECT ON ecommerce_db.product TO 'sales_manager'@'localhost';
GRANT SELECT ON ecommerce_db.orderProduct TO 'sales_manager'@'localhost';
GRANT SELECT ON ecommerce_db.payment TO 'sales_manager'@'localhost';
GRANT SELECT ON ecommerce_db.OrderSummaryView TO 'sales_manager'@'localhost';

-- Customer Service: Limited access with necessary SELECT permissions
GRANT SELECT ON ecommerce_db.customer TO 'customer_service'@'localhost';
GRANT SELECT ON ecommerce_db.orders TO 'customer_service'@'localhost';
GRANT SELECT ON ecommerce_db.product TO 'customer_service'@'localhost';
GRANT SELECT ON ecommerce_db.returnTable TO 'customer_service'@'localhost';
GRANT SELECT ON ecommerce_db.payment TO 'customer_service'@'localhost';
GRANT SELECT ON ecommerce_db.CustomerServiceView TO 'customer_service'@'localhost';
GRANT SELECT, UPDATE ON ecommerce_db.ReturnManagementView TO 'customer_service'@'localhost';

-- Warehouse Staff: Product management with necessary SELECT permissions
GRANT SELECT, UPDATE ON ecommerce_db.product TO 'warehouse_staff'@'localhost';
GRANT SELECT, INSERT, UPDATE ON ecommerce_db.supplierProduct TO 'warehouse_staff'@'localhost';
GRANT SELECT ON ecommerce_db.supplier TO 'warehouse_staff'@'localhost';
GRANT SELECT ON ecommerce_db.productAnalytics TO 'warehouse_staff'@'localhost';

-- Marketing Team: Analytics only
GRANT SELECT ON ecommerce_db.MarketingAnalyticsView TO 'marketing_team'@'localhost';
GRANT SELECT ON ecommerce_db.product TO 'marketing_team'@'localhost';
GRANT SELECT ON ecommerce_db.productAnalytics TO 'marketing_team'@'localhost';
GRANT SELECT ON ecommerce_db.customer TO 'marketing_team'@'localhost';
GRANT SELECT ON ecommerce_db.orders TO 'marketing_team'@'localhost';
GRANT SELECT ON ecommerce_db.discount TO 'marketing_team'@'localhost';

-- Delivery Coordinator: Delivery management with necessary SELECT permissions
GRANT SELECT, UPDATE ON ecommerce_db.delivery TO 'delivery_coordinator'@'localhost';
GRANT SELECT ON ecommerce_db.deliveryPerson TO 'delivery_coordinator'@'localhost';
GRANT SELECT ON ecommerce_db.orders TO 'delivery_coordinator'@'localhost';
GRANT SELECT ON ecommerce_db.customer TO 'delivery_coordinator'@'localhost';
GRANT SELECT ON ecommerce_db.address TO 'delivery_coordinator'@'localhost';
GRANT SELECT ON ecommerce_db.customerAddress TO 'delivery_coordinator'@'localhost';
GRANT SELECT ON ecommerce_db.ActiveDeliveryView TO 'delivery_coordinator'@'localhost';

-- Apply all changes
FLUSH PRIVILEGES;