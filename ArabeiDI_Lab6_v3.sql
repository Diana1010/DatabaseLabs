-- Арабей Диана гр 651001
-- Лабораторная №6 Вариант 3



--1. Создайте хранимую процедуру, которая будет возвращать сводную таблицу (оператор PIVOT), отображающую данные
--   о средней цене (Production.Product.ListPrice) продукта в каждой подкатегории (Production.ProductSubcategory) 
--   по определенному классу (Production.Product.Class). 
--   Список классов передайте в процедуру через входной параметр.

USE AdventureWorks2012;
GO

CREATE PROCEDURE dbo.SubCategoriesByClass (@class NVARCHAR(200))
AS
BEGIN
    DECLARE @query AS NVARCHAR(MAX);
    SET @query = 
	'SELECT *
		FROM (  
			SELECT ps.Name, p.Class, p.ListPrice
			FROM Production.Product p
			INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
		) i
		PIVOT
		(
			AVG(ListPrice)
			FOR Class IN (' + @class + ')
		) AS pvt'
    EXECUTE (@query)
END

EXECUTE dbo.SubCategoriesByClass '[H],[L],[M]'