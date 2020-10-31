USE AdventureWorks2012;
GO

/*
	a) выполните код, созданный во втором задании второй лабораторной работы. 
	Добавьте в таблицу dbo.Address поля AccountNumber NVARCHAR(15) и MaxPrice MONEY.
	Также создайте в таблице вычисляемое поле AccountID, которое будет добавлять к 
	значению в поле AccountNumber приставку ‘ID’.
*/
--Добавляю в Person.Address тк в задании c) нельзя потом сджойнить таблицы с dbo.Address
ALTER TABLE Person.Address
ADD	AccountNumber NVARCHAR(15),
	MaxPrice MONEY,
	AccountID AS 'ID' + AccountNumber;

/*
	b) создайте временную таблицу #Address, с первичным ключом по полю ID.
	Временная таблица должна включать все поля таблицы dbo.Address за исключением поля AccountID
*/
--Делаю идентичную Person.Address тк в задании c) нельзя потом сджойнить таблицы с dbo.Address
CREATE TABLE #Address(
	ID INT IDENTITY(1, 1) PRIMARY KEY,
	AddressID INT NOT NULL,
	AddressLine1 NVARCHAR(60) NOT NULL,
	AddressLine2 NVARCHAR(60),
	City NVARCHAR(30) ,
	StateProvinceID INT NOT NULL,
	PostalCode NVARCHAR(16),
	SpatialLocation GEOGRAPHY,
	rowguid UNIQUEIDENTIFIER NOT NULL,
	ModifiedDate DATETIME,
	AccountNumber NVARCHAR(15),
	MaxPrice MONEY);
SELECT * FROM #Address; --проверка что всё создалось

/*
	c) заполните временную таблицу данными из dbo.Address. 
	Поле AccountNumber заполните данными из таблицы Purchasing.Vendor. 
	Определите максимальную цену продукта (StandardPrice), 
	поставляемого каждым поставщиком (BusinessEntityID) в таблице Purchasing.ProductVendor
	и заполните этими значениями поле MaxPrice. Подсчет максимальной цены осуществите в Common Table Expression (CTE).
*/
--Заполняю данными из Person.Address
WITH MaxPriceCTE
AS (
SELECT		BusinessEntityID,
			MAX(StandardPrice) AS MaxPrice
FROM		Purchasing.ProductVendor
GROUP BY	BusinessEntityID
)

INSERT INTO #Address (
	AddressID,
	AddressLine1, 
	AddressLine2,	
	City, 
	StateProvinceID,	
    PostalCode,	
	SpatialLocation,
	rowguid,
	ModifiedDate, 
	AccountNumber, 
	MaxPrice
)	
SELECT	PA.AddressID, 
		AddressLine1, 
		AddressLine2, 
		City, 
		StateProvinceID, 
		PostalCode, 
		SpatialLocation,
		PA.rowguid,
		PA.ModifiedDate,
		PV.AccountNumber,
		MPCTE.MaxPrice
FROM	Person.Address AS PA
JOIN	Person.BusinessEntityAddress AS PBEA
ON		PBEA.AddressID = PA.AddressID
JOIN	Purchasing.Vendor AS PV
ON		PV.BusinessEntityID = PBEA.BusinessEntityID
JOIN	MaxPriceCTE AS MPCTE
ON		MPCTE.BusinessEntityID = PBEA.BusinessEntityID
SELECT * FROM #Address --проверка что всё создалось

/*
	d) удалите из таблицы dbo.Address одну строку (где ID = 293)
*/
DELETE FROM dbo.Address WHERE ID = 293;

/*
	e) напишите Merge выражение, использующее dbo.Address как target,
	а временную таблицу как source. Для связи target и source используйте ID.
	Обновите поля AccountNumber и MaxPrice, если запись присутствует в source и target.
	Если строка присутствует во временной таблице, но не существует в target, 
	добавьте строку в dbo.Address. Если в dbo.Address присутствует такая строка, 
	которой не существует во временной таблице, удалите строку из dbo.Address.
*/
MERGE dbo.Address AS TARGET
USING #Address AS SOURCE
ON	TARGET.ID = SOURCE.ID
WHEN MATCHED
THEN UPDATE
SET	AccountNumber = source.AccountNumber,
	MaxPrice = source.MaxPrice
WHEN NOT MATCHED BY TARGET
THEN INSERT (
	AddressID,
	AddressLine1,
	AddressLine2,	
	City,
	StateProvinceID,
	PostalCode,
	ModifiedDate,
	AccountNumber,
	MaxPrice)
VALUES (
	source.AddressID,
	source.AddressLine1,
	source.AddressLine2,	
	source.City,
	source.StateProvinceID,
	source.PostalCode,
	source.ModifiedDate,
	source.AccountNumber,
	source.MaxPrice)
WHEN NOT MATCHED BY SOURCE
THEN DELETE;
SELECT * FROM dbo.Address --проверка

