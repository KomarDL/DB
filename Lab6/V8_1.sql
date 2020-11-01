USE AdventureWorks2012
GO

/*
	Создайте хранимую процедуру, которая будет возвращать сводную 
	таблицу (оператор PIVOT), отображающую данные о суммарном количестве 
	заказанных продуктов (Production.WorkOrder.OrderQty) за определенный 
	месяц (DueDate). вывести информацию необходимо дл¤ каждого года. 
	список месяцев передайте в процедуру через входной параметр.
*/
CREATE PROCEDURE dbo.WorkOrdersByMonths
@MONTHS NVARCHAR(1000)
AS
	DECLARE @query NVARCHAR(1000);	
	SET @query = 'SELECT	[Year],' + @MONTHS + '
	FROM	
	(
		SELECT	OrderQty,
				FORMAT(DueDate, ''yyyy'') AS [Year],
				FORMAT(DueDate, ''MMMM'') AS [Month]
		FROM	Production.WorkOrder
	) AS SOURCE
	PIVOT
	(
		SUM(OrderQty)
		FOR [Month]
		IN	(' + @MONTHS +')
	) AS PivotTable'
	EXEC sp_executesql @query
GO

EXECUTE dbo.WorkOrdersByMonths '[January],[February],[March],[April],[May],[June]'
