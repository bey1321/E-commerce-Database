CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

CREATE TABLE customer (
    CustomerID       INT PRIMARY KEY AUTO_INCREMENT,
    FirstName        VARCHAR(50) NOT NULL,
    LastName         VARCHAR(50) NOT NULL,
    DOB              DATE,
    Gender           VARCHAR(20) CHECK (Gender IN ('Male', 'Female')),
    RegistrationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    LoyaltyPoints    INT DEFAULT 0 CHECK(LoyaltyPoints >= 0),
    AccountStatus    VARCHAR(20) DEFAULT 'Active' CHECK(AccountStatus IN ('Active', 'Inactive', 'Suspended', 'Deleted'))
);

CREATE TABLE product (
    ProductID        INT PRIMARY KEY AUTO_INCREMENT,
    ProductName      VARCHAR(100) NOT NULL,
    SKU              VARCHAR(50) UNIQUE NOT NULL,
    Weight           DECIMAL(10,2) CHECK(Weight > 0),
    Warranty         VARCHAR(50),
    Dimensions       VARCHAR(50),
    StockStatus      VARCHAR(20) DEFAULT 'In Stock' CHECK(StockStatus IN ('In Stock', 'Low Stock', 'Out of Stock', 'Discontinued'))
);

CREATE TABLE country (
    CountryID    INT PRIMARY KEY AUTO_INCREMENT,
    CountryName  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE state (
    StateID      INT PRIMARY KEY AUTO_INCREMENT,
    StateName    VARCHAR(100) NOT NULL
);

CREATE TABLE city (
    CityID      INT PRIMARY KEY AUTO_INCREMENT,
    CityName    VARCHAR(100) NOT NULL
);

CREATE TABLE wishList (
    WishListID   INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID   INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
);

CREATE TABLE cart (
    CartID       INT PRIMARY KEY AUTO_INCREMENT,
    CartStatus   VARCHAR(20) DEFAULT 'Active' CHECK(CartStatus IN ('Active', 'Abandoned', 'Checked Out')),
    DateCreated  DATETIME DEFAULT CURRENT_TIMESTAMP,
    LastUpdated  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CustomerID   INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
);

CREATE TABLE category (
    CategoryID   INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE rating (
    RatingID         INT PRIMARY KEY AUTO_INCREMENT,
    EditHistory      TEXT,
    LikeOnReview     VARCHAR(20) DEFAULT 'Neutral' CHECK(LikeOnReview IN ('Like', 'Dislike', 'Neutral')),
    TimeStamp        DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ReviewDate       DATE,
    ReviewText       TEXT,
    VerifiedPurchase TINYINT(1) DEFAULT 0,
    HelpfulCount     INT DEFAULT 0 CHECK(HelpfulCount >= 0),
    RatingValue      INT NOT NULL CHECK(RatingValue BETWEEN 1 AND 5),
    CustomerID       INT NOT NULL,
    ProductID        INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID),
    FOREIGN KEY (ProductID)  REFERENCES product(ProductID)
);

CREATE TABLE discount (
    DiscountID          INT PRIMARY KEY AUTO_INCREMENT,
    DiscountType        VARCHAR(50) NOT NULL,
    DiscountDescription TEXT,
    DiscountValue       DECIMAL(10,2) CHECK(DiscountValue >= 0),
    IsPercentage        TINYINT(1) DEFAULT 0,
    StartDate           DATE NOT NULL,
    EndDate             DATE NOT NULL,
    CHECK(EndDate > StartDate)
);

CREATE TABLE promoCode (
    PromoCodeID   INT PRIMARY KEY AUTO_INCREMENT,
    Code          VARCHAR(50) NOT NULL UNIQUE,
    Status        VARCHAR(20) DEFAULT 'Active' CHECK(Status IN ('Active', 'Inactive', 'Expired')),
    MaxUsage      INT CHECK(MaxUsage > 0),
    TimesUsed     INT DEFAULT 0 CHECK(TimesUsed >= 0),
    StartDate     DATE NOT NULL,
    EndDate       DATE NOT NULL,
    ApplicableTo  VARCHAR(100),
    DiscountID    INT NOT NULL,
    FOREIGN KEY (DiscountID) REFERENCES discount(DiscountID),
    CHECK(EndDate > StartDate)
);

CREATE TABLE orders (
    OrderID      INT PRIMARY KEY AUTO_INCREMENT,
    OrderDate    DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    TotalAmount  DECIMAL(10,2) CHECK(TotalAmount >= 0),
    ShippingFee  DECIMAL(10,2) DEFAULT 0 CHECK(ShippingFee >= 0),
    TrackingID   VARCHAR(50) UNIQUE,
    OrderStatus  VARCHAR(20) DEFAULT 'Pending' CHECK(OrderStatus IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Refunded')),
    CustomerID   INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
);

CREATE TABLE giftCard (
    GiftCardID      INT PRIMARY KEY AUTO_INCREMENT,
    InitialAmount   DECIMAL(10,2) CHECK(InitialAmount > 0),
    CurrentBalance  DECIMAL(10,2) CHECK(CurrentBalance >= 0),
    ExpiryDate      DATE NOT NULL,
    IssueDate       DATE,
    CardStatus      VARCHAR(20) DEFAULT 'Active' CHECK(CardStatus IN ('Active', 'Inactive', 'Expired', 'Redeemed')),
    GiftMessage     TEXT,
    Code            VARCHAR(50) NOT NULL UNIQUE,
    SenderID        INT NOT NULL,
    ReceiverID      INT NOT NULL,
    FOREIGN KEY (SenderID)   REFERENCES customer(CustomerID),
    FOREIGN KEY (ReceiverID) REFERENCES customer(CustomerID),
    CHECK(CurrentBalance <= InitialAmount)
);

CREATE TABLE card (
    CardID           INT PRIMARY KEY AUTO_INCREMENT,
    CardNumber       VARCHAR(20) NOT NULL UNIQUE,
    CardHolderName   VARCHAR(50) NOT NULL,
    ExpiryYear       INT CHECK(ExpiryYear >= 2025),
    ExpiryMonth      INT CHECK(ExpiryMonth BETWEEN 1 AND 12)
);

CREATE TABLE payment (
    PaymentID       INT PRIMARY KEY AUTO_INCREMENT,
    Amount          DECIMAL(10,2) CHECK(Amount >= 0),
    StatementDate   DATE,
    PaymentMethod   VARCHAR(50) NOT NULL CHECK(PaymentMethod IN ('Credit Card', 'Debit Card', 'PayPal', 'Bank Transfer')),
    PaymentStatus   VARCHAR(20) DEFAULT 'Pending' CHECK(PaymentStatus IN ('Pending', 'Completed', 'Failed', 'Refunded')),
    Currency        VARCHAR(3) DEFAULT 'USD',
    PaymentGateway  VARCHAR(50),
    FailureReason   TEXT,
    CardID          INT,
    OrderID         INT NOT NULL UNIQUE,
    FOREIGN KEY (CardID) REFERENCES card(CardID),
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID)
);

CREATE TABLE returnTable (
    ReturnID     INT PRIMARY KEY AUTO_INCREMENT,
    ReturnDate   DATE,
    RefundAmount DECIMAL(10,2) CHECK(RefundAmount >= 0),
    ReturnStatus VARCHAR(20) DEFAULT 'Pending' CHECK(ReturnStatus IN ('Pending', 'Approved', 'Rejected', 'Completed')),
    Reason       TEXT,
    PaymentID    INT NOT NULL,
    OrderID      INT NOT NULL,
    ProductID    INT NOT NULL,
    FOREIGN KEY (PaymentID) REFERENCES payment(PaymentID),
    FOREIGN KEY (OrderID)   REFERENCES orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

CREATE TABLE productAnalytics (
    ProductAnalyticsID INT PRIMARY KEY AUTO_INCREMENT,
    SalesCount         INT DEFAULT 0 CHECK(SalesCount >= 0),
    LastMonthSales     INT DEFAULT 0 CHECK(LastMonthSales >= 0),
    IsNewRelease       TINYINT(1) DEFAULT 0,
    IsBestSeller       TINYINT(1) DEFAULT 0,
    ProductID          INT NOT NULL UNIQUE,
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

CREATE TABLE deliveryPerson (
    DeliveryPersonID   INT PRIMARY KEY AUTO_INCREMENT,
    DeliveryPersonName VARCHAR(100) NOT NULL
);

CREATE TABLE delivery (
    DeliveryID           INT PRIMARY KEY AUTO_INCREMENT,
    DeliveryDate         DATE,
    DeliveryTimeEstimate VARCHAR(50),
    DeliveryFee          DECIMAL(10,2) CHECK(DeliveryFee >= 0),
    DeliveryStatus       VARCHAR(20) DEFAULT 'Pending' CHECK(DeliveryStatus IN ('Pending', 'In Transit', 'Out for Delivery', 'Delivered', 'Failed')),
    AssignedDate         DATE,
    OrderID              INT NOT NULL UNIQUE,
    DeliveryPersonID     INT,
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (DeliveryPersonID) REFERENCES deliveryPerson(DeliveryPersonID)
);

CREATE TABLE address (
    AddressID     INT PRIMARY KEY AUTO_INCREMENT,
    Area          VARCHAR(100),
    Street        VARCHAR(200),
    HouseNo       VARCHAR(20),
    Latitude      DECIMAL(10,8) CHECK(Latitude BETWEEN -90 AND 90),
    Longitude     DECIMAL(11,8) CHECK(Longitude BETWEEN -180 AND 180),
    CityID        INT,
    FOREIGN KEY (CityID) REFERENCES city(CityID)
);

CREATE TABLE supplier (
    SupplierID      INT PRIMARY KEY AUTO_INCREMENT,
    SupplierName    VARCHAR(100) NOT NULL UNIQUE,
    EstablishedDate DATE
);

CREATE TABLE customerAddress (
    AddressID   INT,
    CustomerID  INT,
    PRIMARY KEY (AddressID, CustomerID),
    FOREIGN KEY (AddressID) REFERENCES address(AddressID),
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
);

CREATE TABLE customerRating (
    CustomerID INT,
    RatingID   INT,
    PRIMARY KEY (CustomerID, RatingID),
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID),
    FOREIGN KEY (RatingID) REFERENCES rating(RatingID)
);

CREATE TABLE productCategory (
    ProductID  INT,
    CategoryID INT,
    PRIMARY KEY (ProductID, CategoryID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID),
    FOREIGN KEY (CategoryID) REFERENCES category(CategoryID)
);

CREATE TABLE supplierAddress (
    SupplierID  INT,
    AddressID   INT,
    PRIMARY KEY (SupplierID, AddressID),
    FOREIGN KEY (SupplierID) REFERENCES supplier(SupplierID),
    FOREIGN KEY (AddressID) REFERENCES address(AddressID)
);

CREATE TABLE cartDiscount (
    CartID         INT,
    DiscountID     INT,
    DiscountAmount DECIMAL(10,2) DEFAULT 0 CHECK(DiscountAmount >= 0),
    PRIMARY KEY (CartID, DiscountID),
    FOREIGN KEY (CartID) REFERENCES cart(CartID),
    FOREIGN KEY (DiscountID) REFERENCES discount(DiscountID)
);

CREATE TABLE orderGiftCard (
    OrderID    INT,
    GiftCardID INT,
    PRIMARY KEY (OrderID, GiftCardID),
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (GiftCardID) REFERENCES giftCard(GiftCardID)
);

CREATE TABLE orderProduct (
    OrderID         INT,
    ProductID       INT,
    Quantity        INT DEFAULT 1 CHECK(Quantity > 0),
    PriceAtPurchase DECIMAL(10,2) CHECK(PriceAtPurchase >= 0),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

CREATE TABLE customerDiscount (
    CustomerID INT,
    DiscountID INT,
    PRIMARY KEY (CustomerID, DiscountID),
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID),
    FOREIGN KEY (DiscountID) REFERENCES discount(DiscountID)
);

CREATE TABLE cartProduct (
    CartID       INT,
    ProductID    INT,
    Quantity     INT DEFAULT 1 CHECK(Quantity > 0),
    DateAdded    DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (CartID, ProductID),
    FOREIGN KEY (CartID) REFERENCES cart(CartID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

CREATE TABLE wishListProduct (
    WishListID INT,
    ProductID  INT,
    DateAdded  DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (WishListID, ProductID),
    FOREIGN KEY (WishListID) REFERENCES wishList(WishListID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

CREATE TABLE supplierProduct (
    SupplierID    INT,
    ProductID     INT,
    SupplierPrice DECIMAL(10,2) CHECK(SupplierPrice >= 0),
    SellingPrice  DECIMAL(10,2) CHECK(SellingPrice >= 0),
    Quantity      INT CHECK(Quantity >= 0),
    DateAdded     DATE,
    Description   TEXT,
    PRIMARY KEY (SupplierID, ProductID),
    FOREIGN KEY (SupplierID) REFERENCES supplier(SupplierID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID),
    CHECK(SellingPrice >= SupplierPrice)
);

CREATE TABLE productDiscount (
    DiscountID INT,
    ProductID  INT,
    PRIMARY KEY (DiscountID, ProductID),
    FOREIGN KEY (DiscountID) REFERENCES discount(DiscountID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

CREATE TABLE orderDiscount (
    OrderID        INT,
    DiscountID     INT,
    DiscountAmount DECIMAL(10,2) DEFAULT 0 CHECK(DiscountAmount >= 0),
    PRIMARY KEY (OrderID, DiscountID),
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (DiscountID) REFERENCES discount(DiscountID)
);

CREATE TABLE customerCard (
    CustomerID INT,
    CardID     INT,
    PRIMARY KEY (CustomerID, CardID),
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID),
    FOREIGN KEY (CardID) REFERENCES card(CardID)
);

CREATE TABLE orderCart (
    OrderID INT,
    CartID  INT,
    PRIMARY KEY (OrderID, CartID),
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (CartID) REFERENCES cart(CartID)
);

--------------------------- Tables for Multivalued Attributes (1NF)--------------------------

CREATE TABLE productImageURL (
    ProductID INT,
    ImageURL  VARCHAR(500),
    PRIMARY KEY (ProductID, ImageURL),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

CREATE TABLE customerEmail (
    CustomerID    INT,
    CustomerEmail VARCHAR(255) UNIQUE NOT NULL CHECK(CustomerEmail LIKE '%_@__%.__%'),
    PRIMARY KEY (CustomerID, CustomerEmail),
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
);

CREATE TABLE customerContact (
    CustomerID  INT,
    PhoneNumber VARCHAR(20) NOT NULL,
    PRIMARY KEY (CustomerID, PhoneNumber),
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
);

CREATE TABLE supplierEmail (
    SupplierID    INT,
    SupplierEmail VARCHAR(255) NOT NULL CHECK(SupplierEmail LIKE '%_@__%.__%'),
    PRIMARY KEY (SupplierID, SupplierEmail),
    FOREIGN KEY (SupplierID) REFERENCES supplier(SupplierID)
);

CREATE TABLE supplierContact (
    SupplierID  INT,
    PhoneNumber VARCHAR(20) NOT NULL,
    PRIMARY KEY (SupplierID, PhoneNumber),
    FOREIGN KEY (SupplierID) REFERENCES supplier(SupplierID)
);

CREATE TABLE deliveryPersonContact (
    DeliveryPersonID INT,
    PhoneNumber      VARCHAR(20) NOT NULL,
    PRIMARY KEY (DeliveryPersonID, PhoneNumber),
    FOREIGN KEY (DeliveryPersonID) REFERENCES deliveryPerson(DeliveryPersonID)
);

CREATE TABLE deliveryPersonEmail (
    DeliveryPersonID    INT,
    DeliveryPersonEmail VARCHAR(255) NOT NULL CHECK(DeliveryPersonEmail LIKE '%_@__%.__%'),
    PRIMARY KEY (DeliveryPersonID, DeliveryPersonEmail),
    FOREIGN KEY (DeliveryPersonID) REFERENCES deliveryPerson(DeliveryPersonID)
);

CREATE TABLE profilePictureURL (
    CustomerID        INT,
    ProfilePictureURL VARCHAR(500) NOT NULL,
    PRIMARY KEY (CustomerID, ProfilePictureURL),
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
);

----------------------- Tables for Partial Dependencies (2NF)----------------------------------

CREATE TABLE supplierAddressType (
    AddressID   INT,
    AddressType VARCHAR(20) CHECK(AddressType IN ('Warehouse', 'Office', 'Distribution Center', 'Headquarters', 'Branch Office')),
    PRIMARY KEY (AddressID, AddressType),
    FOREIGN KEY (AddressID) REFERENCES address(AddressID)
);

CREATE TABLE customerAddressType (
    AddressID   INT,
    AddressType VARCHAR(20) CHECK(AddressType IN ('Home', 'Work', 'Billing', 'Shipping')),
    PRIMARY KEY (AddressID, AddressType),
    FOREIGN KEY (AddressID) REFERENCES address(AddressID)
);

CREATE TABLE maxOrderDiscount (
    DiscountId       INT NOT NULL,
    MaxUsagePerOrder INT NOT NULL CHECK(MaxUsagePerOrder > 0),
    PRIMARY KEY (DiscountId),
    FOREIGN KEY (DiscountId) REFERENCES discount(DiscountID)
);

CREATE TABLE maxCartDiscount (
    DiscountId      INT NOT NULL,
    MaxUsagePerCart INT NOT NULL CHECK(MaxUsagePerCart > 0),
    PRIMARY KEY (DiscountId),
    FOREIGN KEY (DiscountId) REFERENCES discount(DiscountID)
);

---------------------------------- Tables for Transitive Dependencies (3NF)--------------------------------------

CREATE TABLE QuantityAvailability(
    Quantity           INT,
    AvailabilityStatus VARCHAR(20) CHECK(AvailabilityStatus IN ('Available', 'Out of Stock')),
    PRIMARY KEY (Quantity)
);

CREATE TABLE ProductCartPrice (
    CartID    INT, 
    ProductID INT,
    PriceAtAdd DECIMAL(10,2) CHECK(PriceAtAdd >= 0),
    PRIMARY KEY (CartID, ProductID),
    FOREIGN KEY (CartID, ProductID) REFERENCES cartProduct(CartID, ProductID)
);
