--Вариант 3 Арабей Диана группа 651001
USE AdventureWorks2012
GO
-- Задание 1
-- 1. Добавьте в таблицу dbo.Address поле AddressType типа nvarchar и размерностью 50 символов:

ALTER TABLE dbo.Address 
	ADD AddressType NVARCHAR(50)
GO

-- 2. Объявите табличную переменную с такой же структурой как dbo.Address и заполните ее данными из dbo.Address. 
--   Заполните поле AddressType значениями из Person.AddressType поля Name;

DECLARE @AddressTable TABLE (
	AddressID int NOT NULL,
	AddressLine1 nvarchar(60) NOT NULL,
	AddressLine2 nvarchar(60) NULL,
	City nvarchar(20) NOT NULL,
	StateProvinceID int NOT NULL,
	PostalCode nvarchar(15) NOT NULL,
	ModifiedDate datetime NOT NULL,
	AddressType nvarchar(50)  NULL
);

INSERT INTO @AddressTable
	(AddressID, AddressLine1, AddressLine2, City, StateProvinceID, PostalCode, ModifiedDate, AddressType)
	(SELECT da.AddressID, da.AddressLine1, da.AddressLine2, da.City, da.StateProvinceID, da.PostalCode, da.ModifiedDate, at.Name
	FROM dbo.Address AS da
	 LEFT OUTER JOIN Person.BusinessEntityAddress as bea
	ON da.AddressID = bea.AddressID
	LEFT  OUTER JOIN Person.AddressType as at
	ON bea.AddressTypeID = at.AddressTypeID)



-- 3.  Обновите поле AddressType в dbo.Address данными из табличной переменной. 
--     Также обновите AddressLine2, если значение в поле NULL — обновите поле данными из AddressLine1;	
UPDATE dbo.Address
		SET AddressLine2 = AddressLine1
		WHERE AddressLine2 IS NULL

UPDATE dbo.Address
	SET AddressType = at.AddressType
	FROM @AddressTable AS at
	WHERE Address.AddressID = at.AddressID



-- 4. Удалите данные из dbo.Address, оставив только по одной строке для каждого AddressType с максимальным AddressID;

DELETE
FROM dbo.Address
WHERE AddressID NOT IN (
	(
		SELECT max(AddressID) AS AddressID
		FROM dbo.Address
		GROUP BY AddressType)
	) 

-- 5. Удалите поле AddressType из таблицы, удалите все созданные ограничения и значения по умолчанию.

-- Значения по умолчанию

SELECT *
FROM sys.default_constraints
WHERE parent_object_id = object_id('dbo.Address') 

--Ограничения
SELECT CONSTRAINT_NAME
FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Address';

ALTER TABLE dbo.Address
	DROP COLUMN AddressType,
		CONSTRAINT CHK_Address_PostalCode, DF_PostalCode;

-- 6. Удалите таблицу dbo.Address:
DROP TABLE dbo.Address;


-- Задание 2

-- 1. Выполните код, созданный во втором задании второй лабораторной работы. 
--   Добавьте в таблицу dbo.Address поля CountryRegionCode NVARCHAR(3) и TaxRate SMALLMONEY. Также создайте в таблице вычисляемое поле DiffMin, считающее разницу между значением в поле TaxRate и минимальной налоговой ставкой 5.00.
ALTER TABLE dbo.Address
	ADD CountryRegionCode NVARCHAR(3), TaxRate SMALLMONEY,
		DiffMin AS (TaxRate - 5.00)
GO

-- 2. Создайте временную таблицу #Address, с первичным ключом по полю AddressID. Временная таблица должна включать все поля таблицы dbo.Address за исключением поля DiffMin.

CREATE TABLE #Address (
	AddressID int NOT NULL PRIMARY KEY,
	AddressLine1 nvarchar(60) NOT NULL,
	AddressLine2 nvarchar(60) NULL,
	City nvarchar(20) NOT NULL,
	StateProvinceID int NOT NULL,
	PostalCode nvarchar(15) NOT NULL,
	ModifiedDate datetime NOT NULL,
	CountryRegionCode NVARCHAR(3) NULL,
	TaxRate SMALLMONEY  NULL
);

-- 3. Заполните временную таблицу данными из dbo.Address. Поле CountryRegionCode заполните значениями из таблицы Person.StateProvince.
--    Поле TaxRate заполните значениями из таблицы Sales.SalesTaxRate. Выберите только те записи, где TaxRate > 5. 
--    Выборку данных для вставки в табличную переменную осуществите в Common Table Expression (CTE).


WITH TaxRateAndCountryRegion_CTE(StateProvinceID, TaxRate,  CountryRegionCode) AS (
	SELECT st.StateProvinceID, st.TaxRate, CountryRegionCode
	FROM Sales.SalesTaxRate as st
	LEFT JOIN Person.StateProvince as sp
	ON st.StateProvinceID = sp.StateProvinceID
	WHERE st.TaxRate > 5
)
INSERT INTO #Address
	(AddressID, AddressLine1, AddressLine2, City, StateProvinceID, PostalCode, ModifiedDate,
		CountryRegionCode, TaxRate)
	(SELECT a.AddressID, a.AddressLine1, a.AddressLine2, a.City, a.StateProvinceID, a.PostalCode, a.ModifiedDate, 
		tracr.CountryRegionCode, tracr.TaxRate
	FROM dbo.Address AS a
	INNER JOIN TaxRateAndCountryRegion_CTE AS tracr
	ON a.StateProvinceID = tracr.StateProvinceID)

-- 4. Удалите из таблицы dbo.Address одну строку (где StateProvinceID = 36)

	DELETE top (1)
	FROM dbo.Address
	WHERE StateProvinceID = 36;

-- 5. напишите Merge выражение, использующее dbo.Address как target, а временную таблицу как source. 
-- Для связи target и source используйте AddressID. Обновите поля CountryRegionCode и TaxRate, если запись присутствует в source и target. Если строка присутствует во временной таблице, но не существует в target, добавьте строку в dbo.Address.
-- Если в dbo.Address присутствует такая строка, которой не существует во временной таблице, удалите строку из dbo.Address

SET IDENTITY_INSERT dbo.Address ON
	MERGE dbo.Address AS target using #Address AS source
	ON target.AddressID = source.AddressID
	WHEN MATCHED THEN
		UPDATE SET target.CountryRegionCode = source.CountryRegionCode, 
			target.TaxRate = source.TaxRate
	WHEN NOT MATCHED THEN
		INSERT (AddressID, AddressLine1, AddressLine2, City, StateProvinceID, PostalCode, ModifiedDate, CountryRegionCode, TaxRate)
		VALUES (source.AddressID, source.AddressLine1, source.AddressLine2, source.City, source.StateProvinceID, source.PostalCode, source.ModifiedDate, source.CountryRegionCode, source.TaxRate)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;
SET IDENTITY_INSERT dbo.Address OFF
		