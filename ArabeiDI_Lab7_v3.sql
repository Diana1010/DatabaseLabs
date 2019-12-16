-- Арабей Диана гр 651001
-- Лабораторная работа №7, вариант 3

--1. Вывести значения полей [BusinessEntityID], [FirstName] и [LastName] из таблицы [Person].[Person] в виде xml
-- Создать временную таблицу и заполнить её данными из переменной, содержащей xml.

USE AdventureWorks2012;
GO

DECLARE @person XML = (
	SELECT p.BusinessEntityID AS "@ID", p.FirstName, p.LastName	FROM Person.Person AS p
	FOR XML PATH('Person'), ROOT('Persons')

)

CREATE TABLE #Persons(
	BusinessEntityID INT,
	FirstName NVARCHAR(50), 
	LastName NVARCHAR(50)
)

INSERT INTO #Persons(BusinessEntityID, FirstName, LastName)
SELECT 
	xmlNode.value('@ID', 'INT'), 
	xmlNode.value('FirstName[1]', 'NVARCHAR(50)'),
	xmlNode.value('LastName[1]', 'NVARCHAR(50)') FROM @person.nodes('/Persons/Person') AS xml(xmlNode)
GO
