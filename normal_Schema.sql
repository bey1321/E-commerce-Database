PRAGMA foreign_keys = ON;
---------------------------------------------------------
-- CUSTOMER
---------------------------------------------------------
CREATE TABLE customer (
    CustomerID       INTEGER PRIMARY KEY AUTOINCREMENT,
    FirstName        VARCHAR(50) NOT NULL,
    LastName         VARCHAR(50) NOT NULL,
    DOB              DATE CHECK(DOB <= CURRENT_DATE),
    Gender VARCHAR(20) CHECK (Gender IN ('Male', 'Female')),
    RegistrationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    LoyaltyPoints    INTEGER DEFAULT 0 CHECK(LoyaltyPoints >= 0),
    AccountStatus    VARCHAR(20) DEFAULT 'Active' CHECK(AccountStatus IN ('Active', 'Inactive', 'Suspended', 'Deleted'))
);

---------------------------------------------------------
-- PRODUCT
---------------------------------------------------------
CREATE TABLE product (
    ProductID        INTEGER PRIMARY KEY AUTOINCREMENT,
    ProductName      VARCHAR(100) NOT NULL,
    SKU              VARCHAR(50) UNIQUE NOT NULL,
    Weight           REAL CHECK(Weight > 0),
    Warranty         VARCHAR(50),
    Dimensions       VARCHAR(50),
);

---------------------------------------------------------
-- COUNTRY
---------------------------------------------------------
CREATE TABLE country (
    CountryID    INTEGER PRIMARY KEY AUTOINCREMENT,
    CountryName  VARCHAR(100) NOT NULL UNIQUE
);

---------------------------------------------------------
-- STATE
---------------------------------------------------------
CREATE TABLE state (
    StateID      INTEGER PRIMARY KEY AUTOINCREMENT,
    StateName    VARCHAR(100) NOT NULL
);

---------------------------------------------------------
-- CITY
---------------------------------------------------------
CREATE TABLE city (
    CityID      INTEGER PRIMARY KEY AUTOINCREMENT,
    CityName    VARCHAR(100) NOT NULL
);

---------------------------------------------------------
-- WISHLIST
---------------------------------------------------------
CREATE TABLE wishList (
    WishListID   INTEGER PRIMARY KEY AUTOINCREMENT,
    CustomerID   INTEGER NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
);

---------------------------------------------------------
-- CART
---------------------------------------------------------
CREATE TABLE cart (
    CartID       INTEGER PRIMARY KEY AUTOINCREMENT,
    CartStatus   VARCHAR(20) DEFAULT 'Active' CHECK(CartStatus IN ('Active', 'Abandoned', 'Checked Out')),
    DateCreated  DATETIME DEFAULT CURRENT_TIMESTAMP,
    LastUpdated  DATETIME DEFAULT CURRENT_TIMESTAMP,
    CustomerID   INTEGER NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
);

---------------------------------------------------------
-- CATEGORY
---------------------------------------------------------
CREATE TABLE category (
    CategoryID   INTEGER PRIMARY KEY AUTOINCREMENT,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);

---------------------------------------------------------
-- RATING
---------------------------------------------------------
CREATE TABLE rating (
    RatingID         INTEGER PRIMARY KEY AUTOINCREMENT,
    EditHistory      TEXT,
    LikeOnReview     VARCHAR(20) DEFAULT 'Neutral' CHECK(LikeOnReview IN ('Like', 'Dislike', 'Neutral')),
    TimeStamp        DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ReviewDate       DATE DEFAULT CURRENT_DATE,
    ReviewText       TEXT,
    VerifiedPurchase BOOLEAN DEFAULT 0,
    HelpfulCount     INTEGER DEFAULT 0 CHECK(HelpfulCount >= 0),
    RatingValue      INTEGER NOT NULL CHECK(RatingValue BETWEEN 1 AND 5),
    CustomerID       INTEGER NOT NULL,
    ProductID        INTEGER NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID),
    FOREIGN KEY (ProductID)  REFERENCES product(ProductID)
);

---------------------------------------------------------
-- PROMO CODE
---------------------------------------------------------
CREATE TABLE promoCode (
    PromoCodeID   INTEGER PRIMARY KEY AUTOINCREMENT,
    Code          VARCHAR(50) NOT NULL UNIQUE,
    Status        VARCHAR(20) DEFAULT 'Active' CHECK(Status IN ('Active', 'Inactive', 'Expired')),
    MaxUsage      INTEGER CHECK(MaxUsage > 0),
    TimesUsed     INTEGER DEFAULT 0 CHECK(TimesUsed >= 0),
    StartDate     DATE NOT NULL,
    EndDate       DATE NOT NULL,
    ApplicableTo  VARCHAR(100),
    DiscountID    INTEGER NOT NULL,
    FOREIGN KEY (DiscountID) REFERENCES discount(DiscountID),
    CHECK(EndDate > StartDate)
);

---------------------------------------------------------
-- ORDER
---------------------------------------------------------
CREATE TABLE orders (
    OrderID      INTEGER PRIMARY KEY AUTOINCREMENT,
    OrderDate    DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    TotalAmount  DECIMAL(10,2) CHECK(TotalAmount >= 0),
    ShippingFee  DECIMAL(10,2) DEFAULT 0 CHECK(ShippingFee >= 0),
    TrackingID   VARCHAR(50) UNIQUE,
    OrderStatus  VARCHAR(20) DEFAULT 'Pending' CHECK(OrderStatus IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Refunded')),
    CustomerID   INTEGER NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
);

---------------------------------------------------------
-- GIFT CARD
---------------------------------------------------------
CREATE TABLE giftCard (
    GiftCardID      INTEGER PRIMARY KEY AUTOINCREMENT,
    InitialAmount   DECIMAL(10,2) CHECK(InitialAmount > 0),
    CurrentBalance  DECIMAL(10,2) CHECK(CurrentBalance >= 0),
    ExpiryDate      DATE NOT NULL,
    IssueDate       DATE DEFAULT CURRENT_DATE,
    CardStatus      VARCHAR(20) DEFAULT 'Active' CHECK(CardStatus IN ('Active', 'Inactive', 'Expired', 'Redeemed')),
    GiftMessage     TEXT,
    Code            VARCHAR(50) NOT NULL UNIQUE,
    SenderID        INTEGER NOT NULL,
    ReceiverID      INTEGER NOT NULL,
    FOREIGN KEY (SenderID)   REFERENCES customer(CustomerID),
    FOREIGN KEY (ReceiverID) REFERENCES customer(CustomerID),
    CHECK(CurrentBalance <= InitialAmount)
);

---------------------------------------------------------
-- RETURN
---------------------------------------------------------
CREATE TABLE returnTable (
    ReturnID     INTEGER PRIMARY KEY AUTOINCREMENT,
    ReturnDate   DATE DEFAULT CURRENT_DATE,
    RefundAmount DECIMAL(10,2) CHECK(RefundAmount >= 0),
    ReturnStatus VARCHAR(20) DEFAULT 'Pending' CHECK(ReturnStatus IN ('Pending', 'Approved', 'Rejected', 'Completed')),
    Reason       TEXT,
    PaymentID    INTEGER NOT NULL,
    OrderID      INTEGER NOT NULL,
    ProductID    INTEGER NOT NULL,
    FOREIGN KEY (PaymentID) REFERENCES payment(PaymentID),
    FOREIGN KEY (OrderID)   REFERENCES orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

---------------------------------------------------------
-- PRODUCT ANALYTICS
---------------------------------------------------------
CREATE TABLE productAnalytics (
    ProductAnalyticsID INTEGER PRIMARY KEY AUTOINCREMENT,
    SalesCount         INTEGER DEFAULT 0 CHECK(SalesCount >= 0),
    LastMonthSales     INTEGER DEFAULT 0 CHECK(LastMonthSales >= 0),
    IsNewRelease       BOOLEAN DEFAULT 0,
    IsBestSeller       BOOLEAN DEFAULT 0,
    ProductID          INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

---------------------------------------------------------
-- DISCOUNT
---------------------------------------------------------
CREATE TABLE discount (
    DiscountID          INTEGER PRIMARY KEY AUTOINCREMENT,
    DiscountType        VARCHAR(50) NOT NULL,
    DiscountDescription TEXT,
    DiscountValue       DECIMAL(10,2) CHECK(DiscountValue >= 0),
    IsPercentage        BOOLEAN DEFAULT 0,
    StartDate           DATE NOT NULL,
    EndDate             DATE NOT NULL,
    CHECK(EndDate > StartDate)
);

---------------------------------------------------------
-- DELIVERY
---------------------------------------------------------
CREATE TABLE delivery (
    DeliveryID           INTEGER PRIMARY KEY AUTOINCREMENT,
    DeliveryDate         DATE,
    DeliveryTimeEstimate VARCHAR(50),
    DeliveryFee          DECIMAL(10,2) CHECK(DeliveryFee >= 0),
    DeliveryStatus       VARCHAR(20) DEFAULT 'Pending' CHECK(DeliveryStatus IN ('Pending', 'In Transit', 'Out for Delivery', 'Delivered', 'Failed')),
    AssignedDate         DATE DEFAULT CURRENT_DATE,
    OrderID              INTEGER NOT NULL UNIQUE,
    DeliveryPersonID     INTEGER,
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (DeliveryPersonID) REFERENCES deliveryPerson(DeliveryPersonID)
);

---------------------------------------------------------
-- DELIVERY PERSON
---------------------------------------------------------
CREATE TABLE deliveryPerson (
    DeliveryPersonID   INTEGER PRIMARY KEY AUTOINCREMENT,
    DeliveryPersonName VARCHAR(100) NOT NULL
);

---------------------------------------------------------
-- PAYMENT
---------------------------------------------------------
CREATE TABLE payment (
    PaymentID       INTEGER PRIMARY KEY AUTOINCREMENT,
    Amount          DECIMAL(10,2) CHECK(Amount >= 0),
    StatementDate   DATE DEFAULT CURRENT_DATE,
    PaymentMethod   VARCHAR(50) NOT NULL CHECK(PaymentMethod IN ('Credit Card', 'Debit Card', 'PayPal', 'Bank Transfer')),
    PaymentStatus   VARCHAR(20) DEFAULT 'Pending' CHECK(PaymentStatus IN ('Pending', 'Completed', 'Failed', 'Refunded')),
    Currency        VARCHAR(3) DEFAULT 'USD',
    PaymentGateway  VARCHAR(50),
    FailureReason   TEXT,
    CardID          INTEGER,
    OrderID         INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (CardID) REFERENCES card(CardID),
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID)
);

---------------------------------------------------------
-- CARD
---------------------------------------------------------
CREATE TABLE card (
    CardID       INTEGER PRIMARY KEY AUTOINCREMENT,
    CardNumber   VARCHAR(20) NOT NULL UNIQUE,
    CardHolderName   VARCHAR(50) NOT NULL,
    ExpiryYear   INTEGER CHECK(ExpiryYear >= 2025),
    ExpiryMonth  INTEGER CHECK(ExpiryMonth BETWEEN 1 AND 12)
);

---------------------------------------------------------
-- ADDRESS
---------------------------------------------------------
CREATE TABLE address (
    AddressID     INTEGER PRIMARY KEY AUTOINCREMENT,
    Area          VARCHAR(100),
    Street        VARCHAR(200),
    HouseNo       VARCHAR(20),
    Latitude      REAL CHECK(Latitude BETWEEN -90 AND 90),
    Longitude     REAL CHECK(Longitude BETWEEN -180 AND 180),
    CityID        INTEGER,
    FOREIGN KEY (CityID)    REFERENCES city(CityID)
);

-- ============================
-- SUPPLIER
-- ============================
CREATE TABLE supplier (
    SupplierID      INTEGER PRIMARY KEY AUTOINCREMENT,
    SupplierName    VARCHAR(100) NOT NULL UNIQUE,
    EstablishedDate DATE CHECK(EstablishedDate <= CURRENT_DATE)
);

-- ============================
-- CustomerAddress
-- ============================
CREATE TABLE customerAddress (
    AddressID   INTEGER,
    CustomerID  INTEGER,
    PRIMARY KEY (AddressID, CustomerID),
    FOREIGN KEY (AddressID) REFERENCES address(AddressID),
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
);

-- ============================
-- CustomerRating
-- ============================
CREATE TABLE customerRating (
    CustomerID INTEGER,
    RatingID   INTEGER,
    PRIMARY KEY (CustomerID, RatingID),
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID),
    FOREIGN KEY (RatingID) REFERENCES rating(RatingID)
);

-- ============================
-- ProductCategory
-- ============================
CREATE TABLE productCategory (
    ProductID  INTEGER,
    CategoryID INTEGER,
    PRIMARY KEY (ProductID, CategoryID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID),
    FOREIGN KEY (CategoryID) REFERENCES category(CategoryID)
);

-- ============================
-- SupplierAddress
-- ============================
CREATE TABLE supplierAddress (
    SupplierID  INTEGER,
    AddressID   INTEGER,
    PRIMARY KEY (SupplierID, AddressID),
    FOREIGN KEY (SupplierID) REFERENCES supplier(SupplierID),
    FOREIGN KEY (AddressID) REFERENCES address(AddressID)
);

-- ============================
-- CartDiscount
-- ============================
CREATE TABLE cartDiscount (
    CartID     INTEGER,
    DiscountID INTEGER,
    DiscountAmount DECIMAL(10,2) DEFAULT 0 CHECK(DiscountAmount >= 0),
    PRIMARY KEY (CartID, DiscountID),
    FOREIGN KEY (CartID) REFERENCES cart(CartID),
    FOREIGN KEY (DiscountID) REFERENCES discount(DiscountID)
);

-- ============================
-- OrderGiftCard
-- ============================
CREATE TABLE orderGiftCard (
    OrderID    INTEGER,
    GiftCardID INTEGER,
    PRIMARY KEY (OrderID, GiftCardID),
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (GiftCardID) REFERENCES giftCard(GiftCardID)
);

-- ============================
-- OrderProduct
-- ============================
CREATE TABLE orderProduct (
    OrderID   INTEGER,
    ProductID INTEGER,
    Quantity  INTEGER DEFAULT 1 CHECK(Quantity > 0),
    PriceAtPurchase DECIMAL(10,2) CHECK(PriceAtPurchase >= 0),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

-- ============================
-- CustomerDiscount
-- ============================
CREATE TABLE customerDiscount (
    CustomerID INTEGER,
    DiscountID INTEGER,
    PRIMARY KEY (CustomerID, DiscountID),
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID),
    FOREIGN KEY (DiscountID) REFERENCES discount(DiscountID)
);

-- ============================
-- CartProduct
-- ============================
CREATE TABLE cartProduct (
    CartID       INTEGER,
    ProductID    INTEGER,
    Quantity     INTEGER DEFAULT 1 CHECK(Quantity > 0),
    DateAdded    DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (CartID, ProductID),
    FOREIGN KEY (CartID) REFERENCES cart(CartID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

-- ============================
-- WishListProduct
-- ============================
CREATE TABLE wishListProduct (
    WishListID INTEGER,
    ProductID  INTEGER,
    DateAdded  DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (WishListID, ProductID),
    FOREIGN KEY (WishListID) REFERENCES wishList(WishListID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

-- ============================
-- SupplierProduct
-- ============================
CREATE TABLE supplierProduct (
    SupplierID    INTEGER,
    ProductID     INTEGER,
    SupplierPrice DECIMAL(10,2) CHECK(SupplierPrice >= 0),
    SellingPrice  DECIMAL(10,2) CHECK(SellingPrice >= 0),
    Quantity      INTEGER CHECK(Quantity >= 0),
    DateAdded          DATE DEFAULT CURRENT_DATE,
    Description        TEXT,
    PRIMARY KEY (SupplierID, ProductID),
    FOREIGN KEY (SupplierID) REFERENCES supplier(SupplierID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID),
    CHECK(SellingPrice >= SupplierPrice)
);

-- ============================
-- ProductDiscount
-- ============================
CREATE TABLE productDiscount (
    DiscountID INTEGER,
    ProductID  INTEGER,
    PRIMARY KEY (DiscountID, ProductID),
    FOREIGN KEY (DiscountID) REFERENCES discount(DiscountID),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

-- ============================
-- OrderDiscount
-- ============================
CREATE TABLE orderDiscount (
    OrderID    INTEGER,
    DiscountID INTEGER,
    DiscountAmount DECIMAL(10,2) DEFAULT 0 CHECK(DiscountAmount >= 0),
    PRIMARY KEY (OrderID, DiscountID),
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (DiscountID) REFERENCES discount(DiscountID)
);

-- ============================
-- CustomerCard
-- ============================
CREATE TABLE customerCard (
    CustomerID INTEGER,
    CardID     INTEGER,
    PRIMARY KEY (CustomerID, CardID),
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID),
    FOREIGN KEY (CardID) REFERENCES card(CardID)
);

-- ============================
-- OrderCart
-- ============================
CREATE TABLE orderCart (
    OrderID INTEGER,
    CartID  INTEGER,
    PRIMARY KEY (OrderID, CartID),
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (CartID) REFERENCES cart(CartID)
);

--------------------------- Tables for Multivalued Attributes (1NF)--------------------------

-- ============================
-- ProductImageURL
-- ============================
CREATE TABLE productImageURL (
    ProductID INTEGER,
    ImageURL  VARCHAR(500),
    PRIMARY KEY (ProductID, ImageURL),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

-- ============================
-- CustomerEmail
-- ============================
CREATE TABLE customerEmail (
    CustomerID    INTEGER,
    CustomerEmail VARCHAR(255) UNIQUE NOT NULL CHECK(CustomerEmail LIKE '%_@__%.__%'),
    PRIMARY KEY (CustomerID, CustomerEmail),
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
);

-- ============================
-- CustomerContact
-- ============================
CREATE TABLE customerContact (
    CustomerID      INTEGER,
    PhoneNumber VARCHAR(20) NOT NULL,
    PRIMARY KEY (CustomerID, PhoneNumber),
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
);

-- ============================
-- SupplierEmail
-- ============================
CREATE TABLE supplierEmail (
    SupplierID    INTEGER,
    SupplierEmail VARCHAR(255) NOT NULL CHECK(SupplierEmail LIKE '%_@__%.__%'),
    PRIMARY KEY (SupplierID, SupplierEmail),
    FOREIGN KEY (SupplierID) REFERENCES supplier(SupplierID)
);

-- ============================
-- SupplierContact
-- ============================
CREATE TABLE supplierContact (
    SupplierID      INTEGER,
    PhoneNumber VARCHAR(20) NOT NULL,
    PRIMARY KEY (SupplierID, PhoneNumber),
    FOREIGN KEY (SupplierID) REFERENCES supplier(SupplierID)
);

-- ============================
-- DeliveryPersonContact
-- ============================
CREATE TABLE deliveryPersonContact (
    DeliveryPersonID      INTEGER,
    PhoneNumber VARCHAR(20) NOT NULL,
    PRIMARY KEY (DeliveryPersonID, PhoneNumber),
    FOREIGN KEY (DeliveryPersonID) REFERENCES deliveryPerson(DeliveryPersonID)
);

-- ============================
-- DeliveryPersonEmail
-- ============================
CREATE TABLE deliveryPersonEmail (
    DeliveryPersonID    INTEGER,
    DeliveryPersonEmail VARCHAR(255) NOT NULL CHECK(DeliveryPersonEmail LIKE '%_@__%.__%'),
    PRIMARY KEY (DeliveryPersonID, DeliveryPersonEmail),
    FOREIGN KEY (DeliveryPersonID) REFERENCES deliveryPerson(DeliveryPersonID)
);

-- ============================
-- ProfilePictureURL
-- ============================
CREATE TABLE profilePictureURL (
    CustomerID        INTEGER,
    ProfilePictureURL VARCHAR(500) NOT NULL,
    PRIMARY KEY (CustomerID, ProfilePictureURL),
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
);

----------------------- Tables for Partial Dependencies (2NF)----------------------------------

-- ============================
-- SupplierAddressType (Updated for 2NF)
-- ============================
CREATE TABLE supplierAddressType (
    AddressID   INTEGER,
    AddressType VARCHAR(20) CHECK(AddressType IN ('Warehouse', 'Office', 'Distribution Center', 'Headquarters', 'Branch Office')),
    PRIMARY KEY (AddressID, AddressType),
    FOREIGN KEY (AddressID) REFERENCES address(AddressID)
);

-- ============================
-- CustomerAddressType (Updated for 2NF)
-- ============================
CREATE TABLE customerAddressType (
    AddressID   INTEGER,
    AddressType VARCHAR(20) CHECK(AddressType IN ('Home', 'Work', 'Billing', 'Shipping')),
    PRIMARY KEY (AddressID, AddressType),
    FOREIGN KEY (AddressID) REFERENCES address(AddressID)
);


-- ================================================================================
-- MaxCartDiscount Table (Updated for 2NF)
-- ================================================================================

CREATE TABLE maxOrderDiscount (
    DiscountId          INTEGER NOT NULL,
    MaxUsagePerOrder    INTEGER NOT NULL CHECK(MaxUsagePerOrder > 0),
    PRIMARY KEY (DiscountId),
    FOREIGN KEY (DiscountId) REFERENCES discount(DiscountID)
);

-- ================================================================================
-- MaxCartDiscount Table (Updated for 2NF)
-- ================================================================================
CREATE TABLE maxCartDiscount (
    DiscountId       INTEGER NOT NULL,
    MaxUsagePerCart  INTEGER NOT NULL CHECK(MaxUsagePerCart > 0),
    PRIMARY KEY (DiscountId),
    FOREIGN KEY (DiscountId) REFERENCES discount(DiscountID)
);

---------------------------------- Tables for Transitive Dependencies (3NF)--------------------------------------

-- ============================
-- ProductCartPrice (Updated for 3NF)
-- ============================
CREATE TABLE ProductCartPrice (
    CartID INTEGER, 
    PriceAtAdd DECIMAL(10,2) CHECK(PriceAtAdd >= 0),
    PRIMARY KEY (CartID, PriceAtAdd),
    FOREIGN KEY (cartID) REFERENCES card(cartID),
    FOREIGN KEY (PriceAtAdd) REFERENCES address(ProductCart)
);

-- ============================
-- QuantityAvailability (Updated for 3NF)
-- ============================
CREATE TABLE QuantityAvailability(
    Quantity INTEGER,
    AvailabilityStatus VARCHAR(20) CHECK(AvailabilityStatus IN ('Available', 'Out of Stock')),
    PRIMARY KEY (Quantity)
);

    