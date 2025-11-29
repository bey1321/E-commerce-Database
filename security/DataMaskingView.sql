USE ecommerce_db;

-- Masked Customer Names
CREATE VIEW MaskedCustomerView AS
SELECT CustomerID,
       CONCAT(SUBSTRING(FirstName,1,1),'****') AS MaskedFirstName,
       CONCAT(SUBSTRING(LastName,1,1),'****') AS MaskedLastName,
       CONCAT('XXXX-XX-', RIGHT(DOB,2)) AS MaskedDOB,
       Gender, RegistrationDate, LoyaltyPoints, AccountStatus
FROM customer;

-- Masked Emails
CREATE VIEW MaskedEmailView AS
SELECT CustomerID,
       CONCAT(SUBSTRING(CustomerEmail,1,3),'****@', SUBSTRING_INDEX(CustomerEmail,'@',-1)) AS MaskedEmail
FROM customerEmail;

-- Masked Phone Numbers
CREATE VIEW MaskedPhoneView AS
SELECT CustomerID, CONCAT('***-***-', RIGHT(PhoneNumber,4)) AS MaskedPhone
FROM customerContact;
