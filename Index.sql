-- For my example database, I created a few useful and less useful indices.

USE SampleDataMart;
GO

-- Fact table usually gets indexes on foreign keys
CREATE NONCLUSTERED INDEX IX_FactSales_Customer
    ON FactSales (CustomerID);

CREATE NONCLUSTERED INDEX IX_FactSales_Product
    ON FactSales (ProductID);

CREATE NONCLUSTERED INDEX IX_FactSales_Date
    ON FactSales (DateID);

-- Dimension tables: often searched by name or description
CREATE NONCLUSTERED INDEX IX_DimCustomer_Name
    ON DimCustomer (CustomerName);

CREATE NONCLUSTERED INDEX IX_DimProduct_Category
    ON DimProduct (Category);

CREATE NONCLUSTERED INDEX IX_DimDate_Date
    ON DimDate (FullDate);

-- less useful
	-- Duplicate of PK (CustomerID already clustered index)
CREATE NONCLUSTERED INDEX IX_DimCustomer_ID_Duplicate
    ON DimCustomer (CustomerID);

-- Low-cardinality index (ProductCategory is often aggregated not filtered)
-- but since Category exists, this simulates a "less useful" one
CREATE NONCLUSTERED INDEX IX_DimProduct_IsElectronics
    ON DimProduct (Category);

-- Rarely queried fact column
CREATE NONCLUSTERED INDEX IX_FactSales_TotalAmount
    ON FactSales (TotalAmount);


--- Now I would run the test, which index is used and not

USE SampleDataMart;
GO

SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.index_id,
    ISNULL(s.user_seeks, 0) AS Seeks,      -- Index used for targeted lookups
    ISNULL(s.user_scans, 0) AS Scans,      -- Full index/table scans
    ISNULL(s.user_lookups, 0) AS Lookups,  -- Extra lookups from non-covered queries
    ISNULL(s.user_updates, 0) AS Updates,  -- Cost: how many times index had to be updated
    (ISNULL(s.user_seeks, 0) + ISNULL(s.user_scans, 0) + ISNULL(s.user_lookups, 0)) AS TotalReads
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats s
    ON i.object_id = s.object_id
   AND i.index_id = s.index_id
   AND s.database_id = DB_ID()   -- only current DB
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
ORDER BY TotalReads DESC, Updates DESC;

--I would expect that none of the indexes were used yet, and the test presents 0 in the statistics.
-- Now I would run some queries:

--1-- Trigger IX_FactSales_Customer
-- This filters by CustomerID, SQL should use the FactSales.CustomerID index
SELECT fs.SaleID, fs.TotalAmount, c.CustomerName
FROM FactSales fs
JOIN DimCustomer c ON fs.CustomerID = c.CustomerID
WHERE fs.CustomerID = 1;

--2-- Trigger IX_FactSales_Product
-- Filter by ProductID, good candidate for Product index
SELECT fs.SaleID, fs.TotalAmount, p.ProductName
FROM FactSales fs
JOIN DimProduct p ON fs.ProductID = p.ProductID
WHERE fs.ProductID = 2;

--3--Trigger IX_FactSales_Date
-- Filter by DateID
SELECT fs.SaleID, fs.TotalAmount, d.FullDate
FROM FactSales fs
JOIN DimDate d ON fs.DateID = d.DateID
WHERE fs.DateID = 20230901;

--4-- Trigger IX_DimCustomer_Name
-- Search customer by name (non-PK lookup)
SELECT CustomerID, CustomerName, Region
FROM DimCustomer
WHERE CustomerName = 'Alice';

--5-- Trigger IX_DimCustomer_Region
-- Region filter (multiple rows returned)
SELECT CustomerID, CustomerName
FROM DimCustomer
WHERE Region = 'South';

--6-- Trigger IX_DimProduct_Category
-- Filter by Category (common reporting scenario)
SELECT ProductID, ProductName
FROM DimProduct
WHERE Category = 'Electronics';

--7-- Trigger IX_DimDate_Date
-- Lookup by date
SELECT DateID, FullDate
FROM DimDate
WHERE FullDate = '2023-09-01';

-- and again run the same test

USE SampleDataMart;
GO

SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.index_id,
    ISNULL(s.user_seeks, 0) AS Seeks,      -- Index used for targeted lookups
    ISNULL(s.user_scans, 0) AS Scans,      -- Full index/table scans
    ISNULL(s.user_lookups, 0) AS Lookups,  -- Extra lookups from non-covered queries
    ISNULL(s.user_updates, 0) AS Updates,  -- Cost: how many times index had to be updated
    (ISNULL(s.user_seeks, 0) + ISNULL(s.user_scans, 0) + ISNULL(s.user_lookups, 0)) AS TotalReads
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats s
    ON i.object_id = s.object_id
   AND i.index_id = s.index_id
   AND s.database_id = DB_ID()   -- only current DB
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
ORDER BY TotalReads DESC, Updates DESC;

-- now the statistics will show numbers

--How to Read Results
--Seeks (good) - index was used efficiently (WHERE CustomerID=5).
--Scans - index/table was scanned (may still be okay for small tables, but watch out on large fact tables).
--Lookups - SQL needed to fetch extra columns (hint: maybe add INCLUDE columns).
--Updates (cost) - every insert/update/delete updates all indexes - too many indexes = slow ETL.
--TotalReads = Seeks + Scans + Lookups - if 0, the index isn’t used at all - candidate to drop.
