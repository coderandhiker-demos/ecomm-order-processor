-- Create EcommerceOrders database
CREATE DATABASE EcommerceOrders;
GO;


USE EcommerceOrders;

-- Create Customers table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100) UNIQUE
);

-- Create Products table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Price DECIMAL(10, 2)
);

-- Create Orders table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME,
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create OrderItems table
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);


-- Insert sample Customers
INSERT INTO Customers (CustomerID, FirstName, LastName, Email)
VALUES
    (1, 'John', 'Doe', 'john.doe@example.com'),
    (2, 'Jane', 'Smith', 'jane.smith@example.com'),
    (3, 'Michael', 'Johnson', 'michael.johnson@example.com'),
    (4, 'Emily', 'Brown', 'emily.brown@example.com'),
    (5, 'David', 'Wilson', 'david.wilson@example.com'),
    (6, 'Olivia', 'Taylor', 'olivia.taylor@example.com'),
    (7, 'James', 'Miller', 'james.miller@example.com'),
    (8, 'Sophia', 'Anderson', 'sophia.anderson@example.com'),
    (9, 'Liam', 'Martinez', 'liam.martinez@example.com'),
    (10, 'Emma', 'Hernandez', 'emma.hernandez@example.com'),
    (11, 'Ethan', 'Garcia', 'ethan.garcia@example.com'),
    (12, 'Ava', 'Lopez', 'ava.lopez@example.com');

-- Insert sample Guitar Models (Products)
INSERT INTO Products (ProductID, ProductName, Price)
VALUES
    (1, 'Stratocaster Classic', 899.99),
    (2, 'Telecaster Deluxe', 799.99),
    (3, 'Les Paul Custom', 1499.99),
    (4, 'SG Standard', 999.99),
    (5, 'Jazzmaster Pro', 1299.99),
    (6, 'Explorer Elite', 1199.99),
    (7, 'Firebird Vintage', 1399.99),
    (8, 'Jumbo Acoustic', 699.99),
    (9, 'Dreadnought Acoustic', 799.99),
    (10, 'ES-335 Semi-Hollow', 1299.99),
    (11, 'Flying V Metal', 1099.99),
    (12, 'Resonator Blues', 599.99),
    (13, 'Classical Nylon', 499.99),
    (14, '12-String Acoustic', 899.99),
    (15, 'Bass Guitar Model A', 799.99),
    (16, 'Precision Bass Classic', 899.99),
    (17, 'Jazz Bass Fusion', 999.99),
    (18, 'Multi-Scale 7-String', 1199.99),
    (19, 'Baritone Electric', 1099.99),
    (20, 'Hollowbody Jazz', 1499.99);

-- Generate sample Orders for random customers and products
DECLARE @MaxOrders INT = 30; -- Total number of sample orders
DECLARE @Counter INT = 1;

WHILE @Counter <= @MaxOrders
BEGIN
    DECLARE @CustomerID INT = FLOOR(RAND() * 12) + 1; -- Random customer ID
    DECLARE @ProductID INT = FLOOR(RAND() * 20) + 1; -- Random product ID
    DECLARE @Quantity INT = FLOOR(RAND() * 5) + 1;   -- Random quantity between 1 and 5

    INSERT INTO Orders (OrderID, CustomerID, OrderDate)
    VALUES (@Counter, @CustomerID, GETDATE());

    INSERT INTO OrderItems (OrderItemID, OrderID, ProductID, Quantity)
    VALUES (@Counter, @Counter, @ProductID, @Quantity);

    SET @Counter = @Counter + 1;
END;
