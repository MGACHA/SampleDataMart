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
