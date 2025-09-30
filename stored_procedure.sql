-- =====================================
-- 5. Stored Procedure for ETL Simulation
-- =====================================

CREATE PROCEDURE usp_LoadNewSalesData
AS
BEGIN
SET NOCOUNT ON;


-- Example: Insert simulated new sales row (in real world, pull from staging/source)
INSERT INTO FactSales (CustomerID, ProductID, DateID, Quantity, TotalAmount)
VALUES (5, 4, 20250110, 1, 800.00);
END;
GO

  -- =====================================
-- 5. Stored Procedure - additional
-- =====================================


use SampleDataMart

-- Create summary table (once)
CREATE TABLE RegionalSalesSummary (
    RunTime DATETIME,
    Region NVARCHAR(50),
    TotalSales DECIMAL(12,2)
);
select * from RegionalSalesSummary
-- Procedure
CREATE PROCEDURE usp_RefreshRegionalSalesSummary
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO RegionalSalesSummary (RunTime, Region, TotalSales)
    SELECT GETDATE(), c.Region, SUM(fs.TotalAmount)
    FROM FactSales fs
    JOIN DimCustomer c ON fs.CustomerID = c.CustomerID
    GROUP BY c.Region;
END;
GO

CREATE PROCEDURE usp_InsertRandomSale
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CustomerID INT, @ProductID INT, @DateID INT, @Quantity INT, @Amount DECIMAL(10,2);

    -- Pick random IDs within existing ranges
    SELECT @CustomerID = FLOOR(RAND() * (SELECT COUNT(*) FROM DimCustomer)) + 1;
    SELECT @ProductID = FLOOR(RAND() * (SELECT COUNT(*) FROM DimProduct)) + 1;
    SELECT @DateID = (SELECT TOP 1 DateID FROM DimDate ORDER BY NEWID());
    SELECT @Quantity = FLOOR(RAND() * 5) + 1;
    SELECT @Amount = @Quantity * (100 + (RAND() * 500)); -- random between 100 and 600 per unit

    INSERT INTO FactSales (CustomerID, ProductID, DateID, Quantity, TotalAmount)
    VALUES (@CustomerID, @ProductID, @DateID, @Quantity, @Amount);
END;
GO
