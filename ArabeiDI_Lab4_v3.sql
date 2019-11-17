-- Вариант 3, Арабей Диана группа 651001

USE [AdventureWorks2012]
GO

-- Задание 1
-- 1. Создайте таблицу Production.WorkOrderHst, которая будет хранить информацию об изменениях в таблице Production.WorkOrder.
CREATE TABLE Production.WorkOrderHst(
	ActionID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Action nvarchar(8) NOT NULL CHECK
		(Action IN ('Insert', 'Update', 'Delete')),
	ModifiedDate datetime NOT NULL,
	SourceID int NOT NULL,
	UserName nvarchar(200) NOT NULL
)

-- 2.Создайте один AFTER триггер для трех операций INSERT, UPDATE, DELETE для таблицы Production.WorkOrder. Триггер должен заполнять таблицу Production.WorkOrderHst с указанием типа операции в поле Action в зависимости от оператора, вызвавшего триггер.

CREATE TRIGGER Production_WorkOrderHst_ActionLog
ON Production.WorkOrder
AFTER
	INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @action varchar(7);
    DECLARE @sourceID int;

    IF EXISTS (SELECT * FROM inserted)
        BEGIN
            IF EXISTS(SELECT * FROM deleted)
                SELECT @action = 'update';
            ELSE
                SELECT @action = 'insert';
			SELECT @sourceID = WorkOrderID
            FROM inserted;
        END;
    ELSE
        BEGIN 
            SELECT @action = 'delete';
            SELECT @sourceID = WorkOrderID
            FROM deleted;
        END;

    INSERT INTO Production.WorkOrderHst
		(Action, ModifiedDate, SourceID, UserName)
    VALUES (@action, GETDATE(), @sourceID, USER_NAME());
END;

--3.Создайте представление VIEW, отображающее все поля таблицы Production.WorkOrder.
	CREATE VIEW VIEW_WorkOrders AS
		SELECT *
		FROM Production.WorkOrder;
	GO 
--4.Вставьте новую строку в Production.WorkOrder через представление. Обновите вставленную строку. 
--Удалите вставленную строку. Убедитесь, что все три операции отображены в Production.WorkOrderHst.

	INSERT INTO Production.WorkOrder
		(ProductID, OrderQty, ScrappedQty, StartDate, DueDate, ModifiedDate)
		VALUES (1, 2, 3, '2019-11-17', GETDATE(), GETDATE())

		select * from Production.WorkOrder

	UPDATE Production.WorkOrder
	SET StartDate= '2020-11-17'
	WHERE ProductID = 1 and OrderQty = 2 and ScrappedQty = 3

	DELETE
	FROM Production.WorkOrder
	WHERE  ProductID = 1 and OrderQty = 2 and ScrappedQty = 3

	SELECT *
	FROM Production.WorkOrderHst

	-- Задание 2
-- 1. Создайте представление VIEW, отображающее данные из таблиц Production.WorkOrder и Production.ScrapReason,
--    а также Name из таблицы Production.Product. Сделайте невозможным просмотр исходного кода представления. 
--    Создайте уникальный кластерный индекс в представлении по полю WorkOrderID.



CREATE VIEW Production.ProductView
	WITH ENCRYPTION, SCHEMABINDING
	AS 
		SELECT  PP.Name as ProductName, pvo.DueDate, pvo.EndDate, pvo.ModifiedDate as workOrderMd, pvo.OrderQty, pvo.ProductID, 
		pvo.ScrappedQty,
		pvo.ScrapReasonID, pvo.StartDate, pvo.StockedQty, pvo.WorkOrderID, psr.ModifiedDate AS SCrapReasonModifiedDate,
		 psr.Name AS ScrapReasonName
		FROM Production.WorkOrder AS pvo 
		INNER JOIN Production.ScrapReason AS psr ON pvo.ScrapReasonID = psr.ScrapReasonID
		INNER JOIN Production.Product AS pp ON pvo.ProductID = pp.ProductID
GO

CREATE UNIQUE CLUSTERED INDEX ID_WorkOrderID ON Production.ProductView (WorkOrderID)
GO

-- 2. Создайте три INSTEAD OF триггера для представления на операции INSERT, UPDATE, DELETE. 
--Каждый триггер должен выполнять соответствующие операции в таблицах Production.WorkOrder и 
--Production.ScrapReason для указанного Product Name. Обновление и удаление строк производите только в таблицах Production.WorkOrder и Production.ScrapReason, но не в Production.Product. 
--В UPDATE триггере не указывайте обновление поля OrderQty для таблицы Production.WorkOrder.

CREATE TRIGGER Production.WorkOrderScrapReasonVIEW_Insert2
ON Production.ProductView
INSTEAD OF INSERT
AS
BEGIN

	INSERT INTO Production.ScrapReason ( Name, ModifiedDate)
	SELECT ScrapReasonName,  SCrapReasonModifiedDate 
	FROM inserted


	INSERT INTO Production.WorkOrder(DueDate,EndDate, ModifiedDate, OrderQty, ProductID, ScrappedQty,
		ScrapReasonID, StartDate)
		select DueDate, EndDate, workOrderMd, OrderQty, PP.ProductID , ScrappedQty,
		psr.ScrapReasonID, StartDate from inserted
		INNER JOIN Production.Product AS pp ON inserted.ProductName = pp.Name
		INNER JOIN Production.ScrapReason AS psr ON inserted.SCrapReasonModifiedDate  = psr.ModifiedDate;
END;
GO


CREATE TRIGGER Production.WorkOrderScrapReasonVIEW_Update ON Production.ProductView
INSTEAD OF UPDATE AS
BEGIN
	UPDATE Production.ScrapReason
	SET Name = inserted.ScrapReasonName,
		ModifiedDate = inserted.SCrapReasonModifiedDate
	FROM inserted
	WHERE  Production.ScrapReason.ScrapReasonID = inserted.ScrapReasonID

	UPDATE Production.WorkOrder
	SET DueDate = inserted.DueDate,
		EndDate = inserted.EndDate,
		ModifiedDate = inserted.workOrderMd,
		ScrappedQty = inserted.ScrappedQty,
		StartDate = inserted.StartDate
	FROM inserted
	WHERE Production.WorkOrder.ProductID = inserted.ProductID
END;
GO


CREATE TRIGGER Production.WorkOrderScrapReasonVIEW_Delete
ON Production.ProductView
INSTEAD OF DELETE
AS
	
	DELETE pwo FROM Production.WorkOrder pwo
	 INNER JOIN deleted ON pwo.ScrapReasonID = deleted.ScrapReasonID
	 INNER JOIN Production.Product AS pp ON deleted.ProductName = pp.Name
	WHERE pwo.ProductID = pp.ProductID;

	DELETE psr FROM Production.ScrapReason psr
	INNER JOIN deleted	ON deleted.ScrapReasonID = psr.ScrapReasonID
GO

select * from Production.ProductView


--3. Вставьте новую строку в представление, указав новые данные для WorkOrder и ScrapReason, но для существующего Product (например для ‘Adjustable Race’). 
--   Триггер должен добавить новые строки в таблицы Production.WorkOrder и Production.ScrapReason для указанного Product Name. Обновите вставленные строки через представление. 
--   Удалите строки.

INSERT INTO Production.ProductView (WorkOrderID,ProductName,  OrderQty,ScrappedQty, StartDate, EndDate,DueDate,WorkOrderMd,ScrapReasonName,SCrapReasonModifiedDate
) 
VALUES ( 1,'Adjustable Race',555, 0, GETDATE(),GETDATE(),GETDATE(), GETDATE(),  'Reason', GETDATE());

UPDATE Production.ProductView
SET ScrapReasonName = 'new reason'
WHERE ProductName = 'Adjustable Race';

DELETE Production.ProductView
WHERE ProductName = 'Adjustable Race';