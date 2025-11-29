-- MySQL Insert Statements for E-commerce Database
-- Make sure to run normal_Schema_MySQL.sql first

USE ecommerce_db;

-- ============================
-- Country
-- ============================
INSERT INTO country (CountryName) VALUES
('United States'),
('United Kingdom'),
('Canada'),
('Germany'),
('France'),
('Australia'),
('Japan'),
('Italy'),
('Spain'),
('Brazil');

-- ============================
-- State
-- ============================
INSERT INTO state (StateName) VALUES
('California'),
('Texas'),
('New York'),
('Ontario'),
('Bavaria'),
('New South Wales'),
('Tokyo'),
('Lombardy'),
('Catalonia'),
('São Paulo');

-- ============================
-- City
-- ============================
INSERT INTO city (CityName) VALUES
('Los Angeles'),
('Houston'),
('New York City'),
('Toronto'),
('Munich'),
('Sydney'),
('Tokyo'),
('Milan'),
('Barcelona'),
('São Paulo');

-- ============================
-- Address
-- ============================
INSERT INTO address (Area, Street, HouseNo, Latitude, Longitude, CityID) VALUES
('Downtown', '123 Main Street', 'A101', 34.0522, -118.2437, 1),
('Midtown', '456 Oak Avenue', 'B205', 29.7604, -95.3698, 2),
('Upper East', '789 Park Lane', 'C302', 40.7128, -74.0060, 3),
('City Center', '321 Maple Drive', 'D150', 43.6532, -79.3832, 4),
('Old Town', '654 Elm Street', 'E220', 48.1351, 11.5820, 5),
('Harbor Side', '987 Beach Road', 'F180', -33.8688, 151.2093, 6),
('Central District', '147 Cherry Blossom', 'G401', 35.6762, 139.6503, 7),
('Fashion District', '258 Via Montenapoleone', 'H102', 45.4642, 9.1900, 8),
('Gothic Quarter', '369 Las Ramblas', 'I203', 41.3851, 2.1734, 9),
('Paulista', '741 Avenida Paulista', 'J304', -23.5505, -46.6333, 10);

-- ============================
-- Customer
-- ============================
INSERT INTO customer (FirstName, LastName, DOB, Gender, LoyaltyPoints, AccountStatus) VALUES
('John', 'Smith', '1990-05-15', 'Male', 150, 'Active'),
('Sarah', 'Johnson', '1985-08-22', 'Female', 320, 'Active'),
('Michael', 'Williams', '1992-03-10', 'Male', 75, 'Active'),
('Emily', 'Brown', '1988-12-03', 'Female', 450, 'Active'),
('David', 'Jones', '1995-07-18', 'Male', 200, 'Active'),
('Jessica', 'Garcia', '1991-11-25', 'Female', 180, 'Active'),
('Daniel', 'Martinez', '1987-04-30', 'Male', 95, 'Active'),
('Sophie', 'Anderson', '1993-09-12', 'Female', 275, 'Active'),
('Ryan', 'Taylor', '1989-06-08', 'Male', 340, 'Active'),
('Isabella', 'Rodriguez', '1994-02-25', 'Female', 125, 'Active');

-- ============================
-- CustomerEmail
-- ============================
INSERT INTO customerEmail (CustomerID, CustomerEmail) VALUES
(1, 'john.smith@email.com'),
(2, 'sarah.j@email.com'),
(3, 'mike.w@email.com'),
(4, 'emily.brown@email.com'),
(5, 'david.jones@email.com'),
(6, 'jessica.g@email.com'),
(7, 'daniel.m@email.com'),
(8, 'sophie.a@email.com'),
(9, 'ryan.t@email.com'),
(10, 'isabella.r@email.com');

-- ============================
-- CustomerContact
-- ============================
INSERT INTO customerContact (CustomerID, PhoneNumber) VALUES
(1, '+1-555-0101'),
(2, '+1-555-0102'),
(3, '+1-555-0103'),
(4, '+1-555-0104'),
(5, '+1-555-0105'),
(6, '+1-555-0106'),
(7, '+1-555-0107'),
(8, '+1-555-0108'),
(9, '+1-555-0109'),
(10, '+1-555-0110');

-- ============================
-- ProfilePictureURL
-- ============================
INSERT INTO profilePictureURL (CustomerID, ProfilePictureURL) VALUES
(1, 'https://example.com/profiles/john.jpg'),
(2, 'https://example.com/profiles/sarah.jpg'),
(3, 'https://example.com/profiles/michael.jpg'),
(4, 'https://example.com/profiles/emily.jpg'),
(5, 'https://example.com/profiles/david.jpg'),
(6, 'https://example.com/profiles/jessica.jpg'),
(7, 'https://example.com/profiles/daniel.jpg'),
(8, 'https://example.com/profiles/sophie.jpg'),
(9, 'https://example.com/profiles/ryan.jpg'),
(10, 'https://example.com/profiles/isabella.jpg');

-- ============================
-- Card
-- ============================
INSERT INTO card (CardNumber, CardHolderName, ExpiryYear, ExpiryMonth) VALUES
('4532123456789012', 'John Smith', 2026, 12),
('5425233430109903', 'Sarah Johnson', 2027, 6),
('378282246310005', 'Michael Williams', 2025, 9),
('6011111111111117', 'Emily Brown', 2028, 3),
('3530111333300000', 'David Jones', 2026, 8),
('5105105105105100', 'Jessica Garcia', 2027, 11),
('4111111111111111', 'Daniel Martinez', 2025, 5),
('4539148803436467', 'Sophie Anderson', 2028, 10),
('5200828282828210', 'Ryan Taylor', 2027, 4),
('6759649826438453', 'Isabella Rodriguez', 2026, 7);

-- ============================
-- CustomerCard
-- ============================
INSERT INTO customerCard (CustomerID, CardID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- ============================
-- Product
-- ============================
INSERT INTO product (ProductName, SKU, Weight, Warranty, Dimensions, StockStatus) VALUES
('Wireless Mouse', 'WM-001', 0.15, '1 Year', '10x6x4 cm', 'In Stock'),
('USB Keyboard', 'KB-002', 0.8, '2 Years', '45x15x3 cm', 'In Stock'),
('HDMI Cable', 'HC-003', 0.1, '6 Months', '200 cm', 'Low Stock'),
('Laptop Stand', 'LS-004', 1.2, '1 Year', '30x25x5 cm', 'In Stock'),
('Webcam HD', 'WC-005', 0.3, '1 Year', '8x8x6 cm', 'In Stock'),
('USB Hub', 'UH-006', 0.2, '1 Year', '10x5x2 cm', 'In Stock'),
('Phone Charger', 'PC-007', 0.18, '1 Year', '8x5x3 cm', 'In Stock'),
('Bluetooth Speaker', 'BS-008', 0.5, '2 Years', '15x8x8 cm', 'In Stock'),
('Gaming Headset', 'GH-009', 0.4, '1 Year', '20x18x10 cm', 'In Stock'),
('Portable SSD', 'SSD-010', 0.12, '3 Years', '10x7x1 cm', 'Low Stock');

-- ============================
-- ProductImageURL
-- ============================
INSERT INTO productImageURL (ProductID, ImageURL) VALUES
(1, 'https://example.com/products/mouse1.jpg'),
(2, 'https://example.com/products/keyboard1.jpg'),
(3, 'https://example.com/products/cable1.jpg'),
(4, 'https://example.com/products/stand1.jpg'),
(5, 'https://example.com/products/webcam1.jpg'),
(6, 'https://example.com/products/hub1.jpg'),
(7, 'https://example.com/products/charger1.jpg'),
(8, 'https://example.com/products/speaker1.jpg'),
(9, 'https://example.com/products/headset1.jpg'),
(10, 'https://example.com/products/ssd1.jpg');

-- ============================
-- Category
-- ============================
INSERT INTO category (CategoryName) VALUES
('Electronics'),
('Accessories'),
('Cables'),
('Computer Peripherals'),
('Mobile Accessories'),
('Office Supplies'),
('Gaming'),
('Audio'),
('Storage'),
('Networking');

-- ============================
-- ProductCategory
-- ============================
INSERT INTO productCategory (ProductID, CategoryID) VALUES
(1, 4),
(2, 4),
(3, 3),
(4, 6),
(5, 1),
(6, 4),
(7, 5),
(8, 8),
(9, 7),
(10, 9);

-- ============================
-- ProductAnalytics
-- ============================
INSERT INTO productAnalytics (SalesCount, LastMonthSales, IsNewRelease, IsBestSeller, ProductID) VALUES
(150, 45, 0, 1, 1),
(230, 67, 0, 1, 2),
(89, 23, 1, 0, 3),
(310, 95, 0, 1, 4),
(175, 52, 1, 0, 5),
(420, 120, 0, 1, 6),
(265, 78, 0, 0, 7),
(198, 65, 1, 0, 8),
(342, 110, 0, 1, 9),
(127, 38, 1, 0, 10);

-- ============================
-- Supplier
-- ============================
INSERT INTO supplier (SupplierName, EstablishedDate) VALUES
('Tech Solutions Inc', '2015-03-20'),
('Global Electronics', '2010-07-15'),
('Premium Supplies', '2018-11-30'),
('Digital Distributors', '2012-05-10'),
('Smart Devices Co', '2019-02-28'),
('Tech World Ltd', '2016-09-05'),
('Gadget Wholesalers', '2020-01-15'),
('Audio Experts Inc', '2017-06-22'),
('Gaming Gear Pro', '2014-10-08'),
('Storage Solutions', '2021-03-12');

-- ============================
-- SupplierEmail
-- ============================
INSERT INTO supplierEmail (SupplierID, SupplierEmail) VALUES
(1, 'info@techsolutions.com'),
(2, 'contact@globalelec.com'),
(3, 'sales@premiumsupplies.com'),
(4, 'orders@digitaldistr.com'),
(5, 'info@smartdevices.com'),
(6, 'sales@techworld.com'),
(7, 'wholesale@gadgets.com'),
(8, 'info@audioexperts.com'),
(9, 'sales@gaminggear.com'),
(10, 'contact@storagesol.com');

-- ============================
-- SupplierContact
-- ============================
INSERT INTO supplierContact (SupplierID, PhoneNumber) VALUES
(1, '+1-800-555-0001'),
(2, '+1-800-555-0002'),
(3, '+1-800-555-0003'),
(4, '+1-800-555-0004'),
(5, '+1-800-555-0005'),
(6, '+1-800-555-0006'),
(7, '+1-800-555-0007'),
(8, '+1-800-555-0008'),
(9, '+1-800-555-0009'),
(10, '+1-800-555-0010');

-- ============================
-- SupplierProduct
-- ============================
INSERT INTO supplierProduct (SupplierID, ProductID, SupplierPrice, SellingPrice, Quantity, Description) VALUES
(1, 1, 20.00, 29.99, 500, 'Ergonomic wireless mouse with 2.4GHz connectivity'),
(2, 2, 55.00, 79.99, 300, 'Mechanical keyboard with cherry switches'),
(3, 3, 8.00, 15.99, 200, 'High-speed HDMI 2.1 cable'),
(4, 4, 35.00, 49.99, 150, 'Adjustable aluminum laptop stand'),
(5, 5, 45.00, 69.99, 250, '1080p webcam with auto-focus'),
(6, 6, 18.00, 29.99, 400, '7-port USB 3.0 hub with power adapter'),
(7, 7, 12.00, 19.99, 600, 'Fast charging USB-C phone charger'),
(8, 8, 30.00, 49.99, 220, 'Portable Bluetooth speaker with 10h battery'),
(9, 9, 65.00, 99.99, 180, 'Gaming headset with 7.1 surround sound'),
(10, 10, 85.00, 129.99, 100, '1TB portable SSD with USB-C');

-- ============================
-- Discount
-- ============================
INSERT INTO discount (DiscountType, DiscountDescription, DiscountValue, IsPercentage, StartDate, EndDate) VALUES
('Seasonal', 'Spring Sale', 15.00, 1, '2024-03-01', '2024-03-31'),
('Loyalty', 'Member Discount', 10.00, 1, '2024-01-01', '2024-12-31'),
('Promotional', 'New Customer', 5.00, 0, '2024-01-01', '2024-06-30'),
('Flash Sale', 'Weekend Special', 20.00, 1, '2024-03-15', '2024-03-17'),
('Bundle', 'Buy 2 Get 1 Free', 33.33, 1, '2024-02-01', '2024-04-30'),
('Clearance', 'End of Season', 25.00, 1, '2024-03-20', '2024-04-15'),
('Student', 'Student Discount', 12.00, 1, '2024-01-01', '2024-12-31'),
('Holiday', 'Summer Sale', 18.00, 1, '2024-06-01', '2024-06-30'),
('VIP', 'Premium Member', 15.00, 1, '2024-01-01', '2024-12-31'),
('Early Bird', 'Morning Deals', 10.00, 0, '2024-01-01', '2024-12-31');

-- ============================
-- ProductDiscount
-- ============================
INSERT INTO productDiscount (DiscountID, ProductID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- ============================
-- CustomerDiscount
-- ============================
INSERT INTO customerDiscount (CustomerID, DiscountID) VALUES
(1, 2),
(2, 1),
(3, 3),
(4, 7),
(5, 5),
(6, 4),
(7, 6),
(8, 9),
(9, 8),
(10, 10);

-- ============================
-- PromoCode
-- ============================
INSERT INTO promoCode (Code, Status, MaxUsage, TimesUsed, StartDate, EndDate, ApplicableTo, DiscountID) VALUES
('SPRING2024', 'Active', 1000, 45, '2024-03-01', '2024-03-31', 'All Products', 1),
('MEMBER10', 'Active', 500, 230, '2024-01-01', '2024-12-31', 'Members Only', 2),
('NEWUSER5', 'Active', 200, 89, '2024-01-01', '2024-06-30', 'New Customers', 3),
('WEEKEND20', 'Active', 300, 156, '2024-03-15', '2024-03-17', 'All Products', 4),
('BUNDLE33', 'Active', 400, 201, '2024-02-01', '2024-04-30', 'Selected Products', 5),
('CLEAR25', 'Active', 250, 98, '2024-03-20', '2024-04-15', 'Clearance Items', 6),
('STUDENT12', 'Active', 600, 345, '2024-01-01', '2024-12-31', 'All Products', 7),
('SUMMER18', 'Active', 800, 125, '2024-06-01', '2024-06-30', 'All Products', 8),
('VIP15', 'Active', 300, 187, '2024-01-01', '2024-12-31', 'VIP Members', 9),
('EARLYBIRD', 'Active', 400, 95, '2024-01-01', '2024-12-31', 'Morning Orders', 10);

-- ============================
-- Cart
-- ============================
INSERT INTO cart (CartStatus, CustomerID) VALUES
('Active', 1),
('Active', 2),
('Checked Out', 3),
('Active', 4),
('Abandoned', 5),
('Active', 6),
('Checked Out', 7),
('Active', 8),
('Active', 9),
('Checked Out', 10);

-- ============================
-- CartProduct
-- ============================
INSERT INTO cartProduct (CartID, ProductID, Quantity) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 2),
(4, 4, 1),
(5, 5, 1),
(6, 6, 2),
(7, 7, 3),
(8, 8, 1),
(9, 9, 1),
(10, 10, 1);

-- ============================
-- ProductCartPrice
-- ============================
INSERT INTO ProductCartPrice (CartID, ProductID, PriceAtAdd) VALUES
(1, 1, 24.99),   -- Wireless Mouse
(2, 2, 39.99),   -- USB Keyboard
(3, 3, 12.99),   -- HDMI Cable
(4, 4, 49.99),   -- Laptop Stand
(5, 5, 89.99),   -- Webcam HD
(6, 6, 29.99),   -- USB Hub
(7, 7, 19.99),   -- Phone Charger
(8, 8, 79.99),   -- Bluetooth Speaker
(9, 9, 129.99),  -- Gaming Headset
(10, 10, 149.99); -- Portable SSD

-- ============================
-- CartDiscount
-- ============================
INSERT INTO cartDiscount (CartID, DiscountID, DiscountAmount) VALUES
(1, 1, 4.50),
(2, 2, 8.00),
(3, 3, 5.00),
(4, 4, 10.00),
(5, 5, 23.33),
(6, 6, 15.00),
(7, 7, 7.20),
(8, 8, 9.00),
(9, 9, 15.00),
(10, 10, 10.00);

-- ============================
-- WishList
-- ============================
INSERT INTO wishList (CustomerID) VALUES
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8),
(9),
(10);

-- ============================
-- WishListProduct
-- ============================
INSERT INTO wishListProduct (WishListID, ProductID) VALUES
(1, 2),
(2, 3),
(3, 1),
(4, 5),
(5, 6),
(6, 7),
(7, 4),
(8, 9),
(9, 10),
(10, 8);

-- ============================
-- Orders
-- ============================
INSERT INTO orders (TotalAmount, ShippingFee, TrackingID, OrderStatus, CustomerID) VALUES
(95.98, 5.99, 'TRK001234567', 'Delivered', 1),
(79.99, 5.99, 'TRK001234568', 'Shipped', 2),
(31.98, 3.99, 'TRK001234569', 'Processing', 3),
(149.99, 7.99, 'TRK001234570', 'Delivered', 4),
(69.99, 5.99, 'TRK001234571', 'Shipped', 5),
(89.98, 5.99, 'TRK001234572', 'Delivered', 6),
(119.97, 7.99, 'TRK001234573', 'Processing', 7),
(49.99, 5.99, 'TRK001234574', 'Shipped', 8),
(99.99, 7.99, 'TRK001234575', 'Delivered', 9),
(129.99, 7.99, 'TRK001234576', 'Pending', 10);

-- ============================
-- OrderProduct
-- ============================
INSERT INTO orderProduct (OrderID, ProductID, Quantity, PriceAtPurchase) VALUES
(1, 1, 2, 29.99),
(2, 2, 1, 79.99),
(3, 3, 2, 15.99),
(4, 4, 3, 49.99),
(5, 5, 1, 69.99),
(6, 6, 3, 29.99),
(7, 7, 6, 19.99),
(8, 8, 1, 49.99),
(9, 9, 1, 99.99),
(10, 10, 1, 129.99);

-- ============================
-- OrderDiscount
-- ============================
INSERT INTO orderDiscount (OrderID, DiscountID, DiscountAmount) VALUES
(1, 1, 14.40),
(2, 2, 8.00),
(3, 3, 5.00),
(4, 4, 30.00),
(5, 5, 23.33),
(6, 6, 22.50),
(7, 7, 14.40),
(8, 8, 9.00),
(9, 9, 15.00),
(10, 10, 10.00);

-- ============================
-- OrderCart
-- ============================
INSERT INTO orderCart (OrderID, CartID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- ============================
-- Payment
-- ============================
INSERT INTO payment (Amount, PaymentMethod, PaymentStatus, Currency, PaymentGateway, FailureReason, CardID, OrderID) VALUES
(95.98, 'Credit Card', 'Completed', 'USD', 'Stripe', NULL, 1, 1),
(79.99, 'Credit Card', 'Completed', 'USD', 'PayPal', NULL, 2, 2),
(31.98, 'Debit Card', 'Completed', 'USD', 'Stripe', NULL, 3, 3),
(149.99, 'Credit Card', 'Completed', 'USD', 'Stripe', NULL, 4, 4),
(69.99, 'PayPal', 'Failed', 'USD', 'PayPal', 'Insufficient Funds', 5, 5),
(89.98, 'Credit Card', 'Completed', 'USD', 'Stripe', NULL, 6, 6),
(119.97, 'Credit Card', 'Completed', 'USD', 'PayPal', NULL, 7, 7),
(49.99, 'Debit Card', 'Completed', 'USD', 'Stripe', NULL, 8, 8),
(99.99, 'Credit Card', 'Completed', 'USD', 'Stripe', NULL, 9, 9),
(129.99, 'Bank Transfer', 'Pending', 'USD', 'Stripe', NULL, 10, 10);

-- ============================
-- GiftCard
-- ============================
INSERT INTO giftCard (InitialAmount, CurrentBalance, ExpiryDate, CardStatus, GiftMessage, Code, SenderID, ReceiverID) VALUES
(50.00, 50.00, '2025-03-12', 'Active', 'Happy Birthday!', 'GC50-ABC123', 1, 2),
(100.00, 75.50, '2025-03-13', 'Active', 'Thank you!', 'GC100-DEF456', 2, 3),
(25.00, 25.00, '2025-03-14', 'Active', 'Congratulations!', 'GC25-GHI789', 3, 1),
(75.00, 60.00, '2025-03-15', 'Active', 'Best wishes!', 'GC75-JKL012', 4, 5),
(200.00, 200.00, '2025-03-16', 'Active', 'For you!', 'GC200-MNO345', 5, 6),
(50.00, 30.00, '2025-03-17', 'Active', 'Enjoy!', 'GC50-PQR678', 6, 7),
(150.00, 150.00, '2025-03-18', 'Active', 'Have fun!', 'GC150-STU901', 7, 4),
(75.00, 50.00, '2025-04-01', 'Active', 'Celebrate!', 'GC75-VWX234', 8, 9),
(100.00, 100.00, '2025-04-05', 'Active', 'Just because!', 'GC100-YZA567', 9, 10),
(125.00, 90.00, '2025-04-10', 'Active', 'Good luck!', 'GC125-BCD890', 10, 8);

-- ============================
-- OrderGiftCard
-- ============================
INSERT INTO orderGiftCard (OrderID, GiftCardID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- ============================
-- Rating
-- ============================
INSERT INTO rating (EditHistory, LikeOnReview, ReviewDate, ReviewText, VerifiedPurchase, HelpfulCount, RatingValue, CustomerID, ProductID) VALUES
('Never edited', 'Like', '2024-03-15', 'Great mouse, very comfortable!', 1, 15, 5, 1, 1),
('Never edited', 'Like', '2024-03-16', 'Excellent keyboard, love the feel', 1, 23, 5, 2, 2),
('Edited once', 'Neutral', '2024-03-17', 'Good cable, works as expected', 1, 8, 4, 3, 3),
('Never edited', 'Like', '2024-03-18', 'Perfect laptop stand, very sturdy', 1, 31, 5, 4, 4),
('Never edited', 'Like', '2024-03-19', 'Webcam quality is amazing!', 1, 19, 5, 5, 5),
('Never edited', 'Like', '2024-03-20', 'USB hub works perfectly', 1, 12, 4, 6, 6),
('Never edited', 'Dislike', '2024-03-21', 'Charger stopped working after 2 weeks', 1, 5, 2, 7, 7),
('Never edited', 'Like', '2024-03-22', 'Sound quality is excellent!', 1, 28, 5, 8, 8),
('Never edited', 'Like', '2024-03-23', 'Best gaming headset I ever had', 1, 45, 5, 9, 9),
('Edited once', 'Like', '2024-03-24', 'Fast and reliable SSD', 1, 17, 4, 10, 10);

-- ============================
-- CustomerRating
-- ============================
INSERT INTO customerRating (CustomerID, RatingID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- ============================
-- DeliveryPerson
-- ============================
INSERT INTO deliveryPerson (DeliveryPersonName) VALUES
('James Miller'),
('Emma Davis'),
('Robert Wilson'),
('Olivia Taylor'),
('William Anderson'),
('Sophia Thomas'),
('Liam Jackson'),
('Ava Martinez'),
('Noah Brown'),
('Mia Johnson');

-- ============================
-- DeliveryPersonEmail
-- ============================
INSERT INTO deliveryPersonEmail (DeliveryPersonID, DeliveryPersonEmail) VALUES
(1, 'james.m@delivery.com'),
(2, 'emma.d@delivery.com'),
(3, 'robert.w@delivery.com'),
(4, 'olivia.t@delivery.com'),
(5, 'william.a@delivery.com'),
(6, 'sophia.t@delivery.com'),
(7, 'liam.j@delivery.com'),
(8, 'ava.m@delivery.com'),
(9, 'noah.b@delivery.com'),
(10, 'mia.j@delivery.com');

-- ============================
-- DeliveryPersonContact
-- ============================
INSERT INTO deliveryPersonContact (DeliveryPersonID, PhoneNumber) VALUES
(1, '+1-555-0201'),
(2, '+1-555-0202'),
(3, '+1-555-0203'),
(4, '+1-555-0204'),
(5, '+1-555-0205'),
(6, '+1-555-0206'),
(7, '+1-555-0207'),
(8, '+1-555-0208'),
(9, '+1-555-0209'),
(10, '+1-555-0210');

-- ============================
-- Delivery
-- ============================
INSERT INTO delivery (DeliveryDate, DeliveryTimeEstimate, DeliveryFee, DeliveryStatus, OrderID, DeliveryPersonID) VALUES
('2024-03-14', '2-3 business days', 5.99, 'Delivered', 1, 1),
('2024-03-15', '2-3 business days', 5.99, 'In Transit', 2, 2),
('2024-03-16', '2-3 business days', 3.99, 'Pending', 3, 3),
('2024-03-17', '1-2 business days', 7.99, 'Delivered', 4, 4),
('2024-03-18', '2-3 business days', 5.99, 'In Transit', 5, 5),
('2024-03-19', '2-3 business days', 5.99, 'Out for Delivery', 6, 6),
('2024-03-20', '1-2 business days', 7.99, 'Pending', 7, 7),
('2024-03-21', '2-3 business days', 5.99, 'In Transit', 8, 8),
('2024-03-22', '1-2 business days', 7.99, 'Delivered', 9, 9),
('2024-03-23', '3-5 business days', 7.99, 'Pending', 10, 10);

-- ============================
-- ReturnTable
-- ============================
INSERT INTO returnTable (RefundAmount, ReturnStatus, Reason, PaymentID, OrderID, ProductID) VALUES
(29.99, 'Approved', 'Defective product', 1, 1, 1),
(79.99, 'Pending', 'Changed mind', 2, 2, 2),
(15.99, 'Rejected', 'Outside return window', 3, 3, 3),
(49.99, 'Approved', 'Wrong item received', 4, 4, 4),
(69.99, 'Pending', 'Not as described', 5, 5, 5),
(29.99, 'Approved', 'Defective', 6, 6, 6),
(19.99, 'Rejected', 'No receipt', 7, 7, 7),
(49.99, 'Completed', 'Product damaged', 8, 8, 8),
(99.99, 'Approved', 'Better price elsewhere', 9, 9, 9),
(129.99, 'Pending', 'Quality issues', 10, 10, 10);

-- ============================
-- CustomerAddress
-- ============================
INSERT INTO customerAddress (AddressID, CustomerID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- ============================
-- SupplierAddress
-- ============================
INSERT INTO supplierAddress (SupplierID, AddressID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- ============================
-- SupplierAddressType (2NF)
-- ============================
INSERT INTO supplierAddressType (AddressID, AddressType) VALUES
(1, 'Warehouse'),
(2, 'Office'),
(3, 'Distribution Center'),
(4, 'Headquarters'),
(5, 'Branch Office'),
(6, 'Warehouse'),
(7, 'Office'),
(8, 'Distribution Center'),
(9, 'Headquarters'),
(10, 'Warehouse');

-- ============================
-- CustomerAddressType (2NF)
-- ============================
INSERT INTO customerAddressType (AddressID, AddressType) VALUES
(1, 'Home'),
(2, 'Work'),
(3, 'Home'),
(4, 'Home'),
(5, 'Work'),
(6, 'Home'),
(7, 'Work'),
(8, 'Home'),
(9, 'Shipping'),
(10, 'Billing');

-- ============================
-- MaxOrderDiscount (2NF)
-- ============================
INSERT INTO maxOrderDiscount (DiscountId, MaxUsagePerOrder) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 2),
(5, 3),
(6, 1),
(7, 1),
(8, 2),
(9, 1),
(10, 1);

-- ============================
-- MaxCartDiscount (2NF)
-- ============================
INSERT INTO maxCartDiscount (DiscountId, MaxUsagePerCart) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 2),
(5, 3),
(6, 1),
(7, 1),
(8, 2),
(9, 1),
(10, 1);
