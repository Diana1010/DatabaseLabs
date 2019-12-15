-- Арабей Диана 
-- лабораторная №5 , вариант 3

-- 1 Создайте scalar-valued функцию, которая будет принимать в качестве входного параметра id заказа 
-- (Purchasing.PurchaseOrderHeader.PurchaseOrderID) и возвращать сумму по заказу из детализированного
--  списка заказов (Purchasing.PurchaseOrderDetail.LineTotal).

USE AdventureWorks2012
GO

CREATE FUNCTION dbo.GetSumPurchase (@ID int)  
RETURNS money
AS  
BEGIN  
     RETURN (SELECT SUM(pod.LineTotal) FROM Purchasing.PurchaseOrderDetail as pod
		WHERE pod.PurchaseOrderID = @ID);  
END;  
GO

SELECT dbo.GetSumPurchase(5) AS TotalPrice

-- 2. Создайте inline table-valued функцию, которая будет принимать в качестве входных параметров id заказчика
--  (Sales.Customer.CustomerID) и количество строк, которые необходимо вывести.

CREATE FUNCTION dbo.GetMostProfitable(@CustomerID INT, @Rows INT) 
RETURNS TABLE AS
RETURN
(
	SELECT TOP(@Rows) * FROM Sales.SalesOrderHeader AS  soh
	WHERE soh.CustomerID = @CustomerID
	ORDER BY soh.TotalDue DESC
);
GO

SELECT * FROM dbo.GetMostProfitable(11003, 2);


-- 3. Вызовите функцию для каждого заказчика, применив оператор CROSS APPLY.
--    Вызовите функцию для каждого заказчика, применив оператор OUTER APPLY.

	SELECT * FROM Sales.Customer AS c CROSS APPLY dbo.GetMostProfitable(c.CustomerID, 2);
	SELECT * FROM Sales.Customer AS c OUTER APPLY dbo.GetMostProfitable(c.CustomerID, 2);
GO

-- 4. Измените созданную inline table-valued функцию, сделав ее multistatement table-valued 
--    (предварительно сохранив для проверки код создания inline table-valued функции).

CREATE FUNCTION dbo.MultiGetMostProfitable (@CustomerID int, @Rows int) 
RETURNS @tempTable TABLE (
	CustomerID int,
	TotalDue money,
	SalesOrderNumber nvarchar(25),
	OrderDate datetime
)
AS
BEGIN
	INSERT INTO @tempTable
		SELECT TOP (@Rows)soh.CustomerID, soh.TotalDue, soh.SalesOrderNumber, soh.OrderDate FROM Sales.SalesOrderHeader as soh
		WHERE soh.CustomerID = @CustomerID	ORDER BY soh.TotalDue DESC		
	RETURN;
END
GO

SELECT * FROM dbo.MultiGetMostProfitable(11003, 2)

