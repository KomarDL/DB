USE AdventureWorks2012;
GO

/*
	a) выполните код, созданный во втором задании второй лабораторной работы. 
	Добавьте в таблицу dbo.Address поля AccountNumber NVARCHAR(15) и MaxPrice MONEY.
	Также создайте в таблице вычисляемое поле AccountID, которое будет добавлять к 
	значению в поле AccountNumber приставку ‘ID’.
*/
ALTER TABLE dbo.Address
ADD	AccountNumber NVARCHAR(15),
	MaxPrice MONEY,
	AccountID AS 'ID' + AccountNumber;

/*
	b) создайте временную таблицу #Address, с первичным ключом по полю ID.
	Временная таблица должна включать все поля таблицы dbo.Address за исключением поля AccountID
*/
CREATE TABLE #Address(
	ID INT IDENTITY(1, 1) PRIMARY KEY,
	AddressID INT,
	AddressLine1 NVARCHAR(64),
	AddressLine2 NVARCHAR(64) NOT NULL,
	City NVARCHAR(32),
	StateProvinceID INT,
	PostalCode NVARCHAR(16),
	ModifiedDate DATETIME,
	AccountNumber NVARCHAR(15),
	MaxPrice MONEY);
SELECT * FROM #Address --проверка что всё создалось

/*
	c) заполните временную таблицу данными из dbo.Address. 
	Поле AccountNumber заполните данными из таблицы Purchasing.Vendor. 
	Определите максимальную цену продукта (StandardPrice), 
	поставляемого каждым поставщиком (BusinessEntityID) в таблице Purchasing.ProductVendor
	и заполните этими значениями поле MaxPrice. Подсчет максимальной цены осуществите в Common Table Expression (CTE).
*/
WITH MyCTE
AS
(
SELECT	dboAddr.AddressID, 
		dboAddr.AddressLine1, 
		dboAddr.AddressLine2, 
		dboAddr.City, 
		dboAddr.StateProvinceID, 
		dboAddr.PostalCode, 
		dboAddr.ModifiedDate,
		(SELECT	AccountNumber
		FROM	Purchasing.Vendor AS PurVendor 
		JOIN	Person.BusinessEntityAddress AS PerBE
		ON		PurVendor.BusinessEntityID = PerBE.BusinessEntityID	
		) AS AccountNumber,
		(SELECT  --dboAddr.AddressID,
				 MAX(StandardPrice) 
		FROM	 Purchasing.ProductVendor AS PrVendor 
		JOIN	 Person.BusinessEntityAddress AS PerBEA
		ON		 PrVendor.BusinessEntityID = PerBEA.BusinessEntityID	
		GROUP BY PrVendor.BusinessEntityID, PerBEA.AddressID
		HAVING   AddressID = dboAddr.AddressID
		) AS MaxPrice
		FROM		dbo.Address AS dboAddr
)

INSERT INTO #Address (
	AddressID,
	AddressLine1, 
	AddressLine2,	
	City, 
	StateProvinceID,	
    PostalCode,	
	ModifiedDate, 
	AccountNumber, 
	MaxPrice
)	SELECT	AddressID, 
			AddressLine1, 
			AddressLine2, 
			City, 
			StateProvinceID, 
			PostalCode, 
			ModifiedDate,
			AccountNumber,
			MaxPrice
	FROM	MyCTE
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
merge dbo.Address as target 
using dbo.#Address as source
on 
	target.ID = source.ID
when matched 
	then update set
		AccountNumber = source.AccountNumber,
		MaxPrice = source.MaxPrice
when not matched  by target
	then insert (
			AddressID,
			AddressLine1,
			AddressLine2,	
			City,
			StateProvinceID,
			PostalCode,
			ModifiedDate,
			AccountNumber,
			MaxPrice)
		values (
			source.AddressID,
			source.AddressLine1,
			source.AddressLine2,	
			source.City,
			source.StateProvinceID,
			source.PostalCode,
			source.ModifiedDate,
			source.AccountNumber,
			source.MaxPrice)
when not matched  by source
	then delete;

select * from dbo.Address 

