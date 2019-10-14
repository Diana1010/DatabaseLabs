-- Вариант 3

USE AdventureWorks2012
GO

-- Задание 1

-- 1. Вывести на экран название отдела, где работает каждый сотрудник в настоящий момент

SELECT employee.businessentityid, 
       employee.jobtitle, 
       department.departmentid, 
       department.NAME 
FROM   humanresources.employee 
       INNER JOIN humanresources.employeedepartmenthistory 
               ON employee.businessentityid = 
                  employeedepartmenthistory.businessentityid 
       INNER JOIN humanresources.department 
               ON employeedepartmenthistory.departmentid = 
                  department.departmentid 

-- 2. Вывести на экран количество сотрудников в каждом отделе.

SELECT department.departmentid, 
       department.NAME, 
       Count(*) AS EmpCount 
FROM   humanresources.employeedepartmenthistory 
       INNER JOIN humanresources.department 
               ON employeedepartmenthistory.departmentid = 
                  department.departmentid 
GROUP  BY department.departmentid, 
          department.NAME 

-- 3. Вывести на экран отчет истории изменения почасовых ставок, как показано в примере.

SELECT employee.jobtitle, 
       employeepayhistory.rate, 
       employeepayhistory.ratechangedate, 
       Concat('The rate for ', employee.jobtitle, ' was set to ', 
       employeepayhistory.rate, ' at ', 
       Format(employeepayhistory.ratechangedate, 
       'dd MMM yyyy')) AS 'Report' 
FROM   humanresources.employee 
       INNER JOIN humanresources.employeepayhistory 
               ON employee.businessentityid = 
                  employeepayhistory.businessentityid 


-- Задание 2

--  1. Создайте таблицу dbo.Address с такой же структурой, как Person.Address, кроме полей geography, uniqueidentifier, 
--   не включая индексы, ограничения и триггеры



CREATE TABLE [dbo].[Address](

	[AddressIDъ int IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[AddressLine1] nvarchar(60) NOT NULL,
	[AddressLine2] nvarchar(60) NULL,
	[City] nvarchar(30) NOT NULL,
	[StateProvinceID] int NOT NULL,
	[PostalCode] nvarchar(15) NOT NULL,
	[ModifiedDate] datetime NOT NULL
)

-- 2. Используя инструкцию ALTER TABLE, создайте для таблицы dbo.Address составной первичный ключ из полей StateProvinceID и PostalCode.

ALTER TABLE [dbo].[Address]
	ADD  PRIMARY KEY (StateProvinceID, PostalCode)
GO

-- 3. Используя инструкцию ALTER TABLE, создайте для таблицы dbo.Address ограничение для поля PostalCode, запрещающее заполнение этого поля буквами.

ALTER TABLE [dbo].[Address]
	ADD CONSTRAINT CHK_Address_PostalCode
	CHECK (PostalCode NOT LIKE '%[A-Za-z]%');
GO

-- 4. Используя инструкцию ALTER TABLE, создайте для таблицы dbo.Address ограничение DEFAULT для поля ModifiedDate, задайте значение по умолчанию текущую дату и время;

ALTER TABLE [dbo].[Address]
	ADD CONSTRAINT DF_PostalCode DEFAULT (GetUtcDate()) FOR PostalCode;
GO

-- 5. заполните новую таблицу данными из Person.Address. Выберите для вставки только те адреса, где значение поля CountryRegionCode = ‘US’ 
--    из таблицы StateProvince. Также исключите данные, где PostalCode содержит буквы. 
--    Для группы данных из полей StateProvinceID и PostalCode выберите только строки с максимальным AddressID 


INSERT INTO [dbo].[Address] 
            (addressline1, 
             addressline2, 
             city, 
             stateprovinceid, 
             postalcode, 
             modifieddate) 
(SELECT a.addressline1, 
        a.addressline2, 
        a.city, 
        a.stateprovinceid, 
        a.postalcode, 
        a.modifieddate 
 FROM   (SELECT TOP(1) WITH ties * 
         FROM   person.address 
         ORDER  BY Row_number() 
                     OVER ( 
                       partition BY stateprovinceid, postalcode 
                       ORDER BY addressid DESC)) AS a 
        INNER JOIN person.stateprovince AS st 
                ON a.stateprovinceid = st.stateprovinceid 
                   AND st.countryregioncode = 'US' 
                   AND a.postalcode NOT LIKE '%[A-Za-z]%') 


-- 6. Уменьшите размер поля City на NVARCHAR(20).

ALTER TABLE [dbo].[Address]
	ALTER COLUMN City NVARCHAR(20) NOT NULL