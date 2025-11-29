USE ecommerce_db;

CREATE TABLE security_log (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    EventType VARCHAR(50) NOT NULL,
    UserAttempted VARCHAR(50) NOT NULL,
    TableAccessed VARCHAR(50),
    ActionAttempted VARCHAR(100),
    IPAddress VARCHAR(45),
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    Details TEXT,
    Severity VARCHAR(20)
);
