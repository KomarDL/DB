USE AdventureWorks2012
GO

/*
	a) создайте представление VIEW, отображающее данные из таблиц 
	Person.CountryRegion и Sales.SalesTerritory. создайте уникальный 
	кластерный индекс в представлении по полю TerritoryID.
*/
CREATE VIEW CR_ST_View
WITH SCHEMABINDING
AS SELECT	PCR.CountryRegionCode,
			PCR.ModifiedDate AS CRModifiedDate,
			PCR.Name AS CRName,
			SST.CostLastYear,
			SST.CostYTD,
			SST.[Group],
			SST.ModifiedDate AS STModifiedDate,
			SST.Name AS STName,
			SST.rowguid,
			SST.SalesLastYear,
			SST.SalesYTD,
			SST.TerritoryID
FROM Person.CountryRegion AS PCR
JOIN Sales.SalesTerritory AS SST
ON PCR.CountryRegionCode = SST.CountryRegionCode;
GO
CREATE UNIQUE CLUSTERED INDEX CR_ST_Index
ON dbo.CR_ST_View (TerritoryID);
GO

/*
	b) создайте один INSTEAD OF триггер дл¤ представлени¤ на три
	операции INSERT, UPDATE, DELETE. триггер должен выполн¤ть 
	соответствующие операции в таблицах Person.CountryRegion и Sales.SalesTerritory.
*/
CREATE TRIGGER IO_TRIGGER
ON dbo.CR_ST_View
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM INSERTED)
	BEGIN
		DECLARE @crr NVARCHAR(3);
		SELECT @crr = DELETED.CountryRegionCode FROM DELETED;

		DELETE FROM Sales.SalesTerritory
		WHERE CountryRegionCode = @crr;
			
		DELETE FROM Person.CountryRegion
		WHERE CountryRegionCode = @crr;
	END ELSE IF NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		IF NOT EXISTS	(SELECT * 
						FROM	Person.CountryRegion AS PCR 
						JOIN	INSERTED
						ON		INSERTED.CountryRegionCode = PCR.CountryRegionCode)

			INSERT INTO Person.CountryRegion(
				CountryRegionCode,
				Name,
				ModifiedDate
			) SELECT	INSERTED.CountryRegionCode,
						INSERTED.CRName,
						INSERTED.CRModifiedDate
						FROM INSERTED;
		ELSE
			UPDATE Person.CountryRegion
			SET	Name = INSERTED.CRName,
				ModifiedDate = INSERTED.CRModifiedDate
			FROM INSERTED
			WHERE Person.CountryRegion.CountryRegionCode = INSERTED.CountryRegionCode;

		INSERT INTO Sales.SalesTerritory (
			Name,
			CountryRegionCode,
			[Group],
			SalesYTD,
			SalesLastYear,
			CostYTD,
			CostLastYear,
			ModifiedDate
		)SELECT INSERTED.STName,
				INSERTED.CountryRegionCode,
				INSERTED.[Group],
				INSERTED.SalesYTD,
				INSERTED.SalesLastYear,
				INSERTED.CostYTD,
				INSERTED.CostLastYear,
				INSERTED.STModifiedDate
		FROM INSERTED;
	END
	ELSE
	BEGIN
		UPDATE Person.CountryRegion
		SET Name = INSERTED.CRName,
			ModifiedDate = INSERTED.CRModifiedDate
		FROM Person.CountryRegion AS PCR
		JOIN INSERTED 
		ON PCR.CountryRegionCode = INSERTED.CountryRegionCode;

		UPDATE Sales.SalesTerritory
		SET Name = INSERTED.STName,
			[Group] = INSERTED.[Group],
			SalesYTD= INSERTED.SalesYTD,
			SalesLastYear= INSERTED.SalesLastYear,
			CostYTD= INSERTED.CostYTD,
			CostLastYear= INSERTED.CostLastYear,
			ModifiedDate = INSERTED.STModifiedDate
		FROM Sales.SalesTerritory AS ST
		JOIN INSERTED
		ON ST.TerritoryID = INSERTED.TerritoryID;
	END
END

/*
	c) вставьте новую строку в представление, указав новые данные для 
	CountryRegion и SalesTerritory. триггер должен добавить новые строки 
	в таблицы Person.CountryRegion и Sales.SalesTerritory. 
	обновите вставленные строки через представление. удалите строки.
*/
INSERT INTO dbo.CR_ST_View
(
	CRModifiedDate,
	STName,
	CountryRegionCode,
	CRName,
	[Group],
	SalesYTD,
	SalesLastYear,
	CostYTD,
	CostLastYear,
	rowguid,
	STModifiedDate
) VALUES (
	GETDATE(),
	'MINSK',
	'BEL',
	'MINSK',
	'RU',
	123.4,
	56.7,
	58.0,
	12.0,
	NEWID(),
	GETDATE()
);

UPDATE dbo.CR_ST_View
SET	CRName = 'HELLO',
	[Group] ='RU',
	SalesLastYear = 123.0
WHERE CountryRegionCode = 'BEL';

DELETE FROM dbo.CR_ST_View
WHERE CountryRegionCode = 'BEL';