USE ecommerce_db;

-- Revoke INSERT privilege
REVOKE INSERT ON ecommerce_db.orders FROM 'customer_service'@'localhost';

-- Revoke all privileges for former employee
REVOKE ALL PRIVILEGES ON ecommerce_db.customer FROM 'former_employee'@'localhost';

-- Revoke only grant option
REVOKE GRANT OPTION FOR SELECT ON ecommerce_db.customer FROM 'sales_manager'@'localhost';
