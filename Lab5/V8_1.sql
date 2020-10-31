USE AdventureWorks2012
GO

/*
	Создайте scalar-valued функцию, которая будет принимать в 
	качестве входного параметра id модели для продукта 
	(Production.ProductModel.ProductModelID) и возвращать суммарную стоимость
	 продуктов данной модели (Production.Product.ListPrice).
*/
CREATE FUNCTION dbo.ProductSum(@ProductModelID INT)  
RETURNS MONEY   
AS   
BEGIN  
    DECLARE @RESULT MONEY;  
    SELECT @RESULT = SUM(PP.ListPrice)   
    FROM Production.Product AS PP   
    WHERE PP.ProductModelID = @ProductModelID   
    IF (@RESULT IS NULL)   
        SET @RESULT = 0;  
    RETURN @RESULT;  
END; 
GO
/*
	Создайте inline table-valued функцию, которая будет принимать 
	в качестве входного параметра id заказчика (Sales.Customer.CustomerID), 
	а возвращать 2 последних заказа, оформленных заказчиком из Sales.SalesOrderHeader.
*/
CREATE FUNCTION dbo.LastSales (@CustomerID INT)  
RETURNS TABLE  
AS  
RETURN   
(  
    SELECT		TOP(2) *
	FROM		Sales.SalesOrderHeader AS SSH
	WHERE		SSH.CustomerID = @CustomerID
	ORDER BY	SSH.OrderDate DESC
);  
GO
/*
	Вызовите функцию для каждого заказчика, применив оператор CROSS APPLY. 
	Вызовите функцию для каждого заказчика, применив оператор OUTER APPLY.
*/
SELECT		*
FROM		Sales.Customer AS SC
CROSS APPLY	dbo.LastSales(SC.CustomerID)

SELECT		*
FROM		Sales.Customer AS SC
OUTER APPLY	dbo.LastSales(SC.CustomerID)
GO
/*
	Измените созданную inline table-valued функцию, сделав ее multistatement table-valued 
	(предварительно сохранив для проверки код создания inline table-valued функции).
*/
CREATE FUNCTION dbo.ProductSumMulti(@CustomerID INT)  
RETURNS @RESULT TABLE (
	[SalesOrderID] int NOT NULL,
	[RevisionNumber] tinyint NOT NULL,
	[OrderDate] datetime NOT NULL,
	[DueDate] datetime NOT NULL,
	[ShipDate] datetime NULL,
	[Status] tinyint NOT NULL,
	[OnlineOrderFlag] dbo.Flag NOT NULL,
	[SalesOrderNumber]  AS (isnull(N'SO'+CONVERT(nvarchar(23),[SalesOrderID]),N'*** ERROR ***')),
	[PurchaseOrderNumber] dbo.OrderNumber NULL,
	[AccountNumber] dbo.AccountNumber NULL,
	[CustomerID] int NOT NULL,
	[SalesPersonID] int NULL,
	[TerritoryID] int NULL,
	[BillToAddressID] int NOT NULL,
	[ShipToAddressID] int NOT NULL,
	[ShipMethodID] int NOT NULL,
	[CreditCardID] int NULL,
	[CreditCardApprovalCode] varchar(15) NULL,
	[CurrencyRateID] int NULL,
	[SubTotal] money NOT NULL,
	[TaxAmt] money NOT NULL,
	[Freight] money NOT NULL,
	[TotalDue]  AS (isnull(([SubTotal]+[TaxAmt])+[Freight],(0))),
	[Comment] nvarchar(128) NULL,
	[rowguid] uniqueidentifier ROWGUIDCOL  NOT NULL,
	[ModifiedDate] datetime NOT NULL
	)
AS   
BEGIN  
	INSERT INTO	@RESULT (	[SalesOrderID],
							[RevisionNumber],
							[OrderDate],
							[DueDate],
							[ShipDate],
							[Status],
							[OnlineOrderFlag],
							[PurchaseOrderNumber],
							[AccountNumber],
							[CustomerID],
							[SalesPersonID],
							[TerritoryID],
							[BillToAddressID],
							[ShipToAddressID],
							[ShipMethodID],
							[CreditCardID],
							[CreditCardApprovalCode],
							[CurrencyRateID],
							[SubTotal],
							[TaxAmt],
							[Freight],
							[Comment],
							[rowguid],
							[ModifiedDate])
		SELECT		TOP(2)	[SalesOrderID],
							[RevisionNumber],
							[OrderDate],
							[DueDate],
							[ShipDate],
							[Status],
							[OnlineOrderFlag],
							[PurchaseOrderNumber],
							[AccountNumber],
							[CustomerID],
							[SalesPersonID],
							[TerritoryID],
							[BillToAddressID],
							[ShipToAddressID],
							[ShipMethodID],
							[CreditCardID],
							[CreditCardApprovalCode],
							[CurrencyRateID],
							[SubTotal],
							[TaxAmt],
							[Freight],
							[Comment],
							[rowguid],
							[ModifiedDate]
		FROM		Sales.SalesOrderHeader AS SSH
		WHERE		SSH.CustomerID = @CustomerID
		ORDER BY	SSH.OrderDate DESC
	RETURN;
END; 
GO