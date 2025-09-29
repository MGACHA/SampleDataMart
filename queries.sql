-- =====================================
-- 7. Practice Queries (for learning)
-- =====================================

use SampleDataMart;

-- 1) Basic join: show all sales with customer and product names
SELECT fs.SaleID, c.CustomerName, p.ProductName, d.FullDate, fs.Quantity, fs.TotalAmount
FROM FactSales fs
JOIN DimCustomer c ON fs.CustomerID = c.CustomerID
JOIN DimProduct p ON fs.ProductID = p.ProductID
JOIN DimDate d ON fs.DateID = d.DateID;

-- 2) Total sales by customer
SELECT c.CustomerName, SUM(fs.TotalAmount) AS TotalSpent
FROM FactSales fs
JOIN DimCustomer c ON fs.CustomerID = c.CustomerID
GROUP BY c.CustomerName
ORDER BY TotalSpent DESC;

-- 3) Total sales by product category
SELECT p.Category, SUM(fs.TotalAmount) AS TotalSales
FROM FactSales fs
JOIN DimProduct p ON fs.ProductID = p.ProductID
GROUP BY p.Category;

-- 4) Sales trend by date
SELECT d.FullDate, SUM(fs.TotalAmount) AS SalesPerDay
FROM FactSales fs
JOIN DimDate d ON fs.DateID = d.DateID
GROUP BY d.FullDate
ORDER BY d.FullDate;

-- 5) Region-level report
SELECT c.Region, SUM(fs.TotalAmount) AS RegionalSales
FROM FactSales fs
JOIN DimCustomer c ON fs.CustomerID = c.CustomerID
GROUP BY c.Region;

-- 6) Top N query: top 2 customers by spending
SELECT TOP 2 c.CustomerName, SUM(fs.TotalAmount) AS TotalSpent
FROM FactSales fs
JOIN DimCustomer c ON fs.CustomerID = c.CustomerID
GROUP BY c.CustomerName
ORDER BY TotalSpent DESC;

-- 7) Check fact table size (row count)
SELECT COUNT(*) AS FactSalesRowCount FROM FactSales;
