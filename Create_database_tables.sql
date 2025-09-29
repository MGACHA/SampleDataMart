-- =====================================
-- 1. Create Database
-- =====================================
CREATE DATABASE SampleDataMart;
GO

USE SampleDataMart;
GO

-- =====================================
-- 2. Dimension Tables
-- =====================================
CREATE TABLE DimCustomer (
CustomerID INT PRIMARY KEY IDENTITY(1,1),
CustomerName NVARCHAR(100),
Region NVARCHAR(50)
);

--drop table DimCustomer

CREATE TABLE DimProduct (
ProductID INT PRIMARY KEY IDENTITY(1,1),
ProductName NVARCHAR(100),
Category NVARCHAR(50)
);

-- drop table DimProduct;

CREATE TABLE DimDate (
DateID INT PRIMARY KEY, -- YYYYMMDD format
FullDate DATE,
Year INT,
Month INT,
Day INT
);

--drop table DimDate
-- =====================================
-- 3. Fact Table
-- =====================================
CREATE TABLE FactSales (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES DimCustomer(CustomerID),
    ProductID INT FOREIGN KEY REFERENCES DimProduct(ProductID),
    DateID INT FOREIGN KEY REFERENCES DimDate(DateID),
    Quantity INT,
    TotalAmount DECIMAL(10,2)
);
--Drop table factsales

-- =====================================
-- 4. Sample Data Inserts (expanded)
-- =====================================
-- Customers
INSERT INTO DimCustomer (CustomerName, Region)
VALUES ('Alice Johnson', 'North'),
('Bob Smith', 'South'),
('Charlie Lee', 'East'),
('Diana Prince', 'West'),
('Ethan Brown', 'North'),
('Fiona Davis', 'South'),
('George Wilson', 'East'),
('Hannah Taylor', 'West');


-- Products
INSERT INTO DimProduct (ProductName, Category)
VALUES ('Laptop', 'Electronics'),
('Desk Chair', 'Furniture'),
('Coffee Machine', 'Appliances'),
('Smartphone', 'Electronics'),
('Bookshelf', 'Furniture'),
('Blender', 'Appliances'),
('Tablet', 'Electronics'),
('Office Desk', 'Furniture');

-- Dates (10 sample days)
INSERT INTO DimDate (DateID, FullDate, Year, Month, Day)
VALUES (20250101, '2025-01-01', 2025, 1, 1),
(20250102, '2025-01-02', 2025, 1, 2),
(20250103, '2025-01-03', 2025, 1, 3),
(20250104, '2025-01-04', 2025, 1, 4),
(20250105, '2025-01-05', 2025, 1, 5),
(20250106, '2025-01-06', 2025, 1, 6),
(20250107, '2025-01-07', 2025, 1, 7),
(20250108, '2025-01-08', 2025, 1, 8),
(20250109, '2025-01-09', 2025, 1, 9),
(20250110, '2025-01-10', 2025, 1, 10);


-- Sales Fact (20 rows)
INSERT INTO FactSales (CustomerID, ProductID, DateID, Quantity, TotalAmount)
VALUES (1, 1, 20250101, 1, 1200.00),
(2, 2, 20250102, 2, 300.00),
(3, 3, 20250103, 1, 150.00),
(4, 4, 20250104, 1, 800.00),
(5, 5, 20250105, 3, 450.00),
(6, 6, 20250106, 2, 180.00),
(7, 7, 20250107, 1, 400.00),
(8, 8, 20250108, 1, 350.00),
(1, 2, 20250102, 1, 150.00),
(2, 4, 20250103, 1, 800.00),
(3, 1, 20250104, 1, 1200.00),
(4, 6, 20250105, 2, 180.00),
(5, 7, 20250106, 1, 400.00),
(6, 3, 20250107, 1, 150.00),
(7, 5, 20250108, 2, 300.00),
(8, 1, 20250109, 1, 1200.00),
(1, 8, 20250110, 1, 350.00),
(2, 3, 20250101, 1, 150.00),
(3, 2, 20250102, 2, 300.00),
(4, 5, 20250103, 1, 150.00);
;






