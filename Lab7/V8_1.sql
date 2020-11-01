USE AdventureWorks2012
GO

/*
	8) Вывести значения полей [AddressID], [City]из таблицы
	 [Person].[Address] и полей [StateProvinceID] и 
	 [CountryRegionCode] из таблицы [Person].[StateProvince] 
	 в виде xml, сохраненного в переменную.
*/
DECLARE @xml XML

SET @xml = (
    SELECT	PA.AddressID AS '@ID',
			PA.City AS 'City',
			PSP.StateProvinceID AS 'Province/@ID',
			PSP.CountryRegionCode AS 'Province/Region'
    FROM	[Person].[Address] AS PA
	JOIN	Person.StateProvince AS PSP
	ON		PSP.StateProvinceID = PA.StateProvinceID
    FOR XML
        PATH ('Address'),
		ROOT ('Addresses')
)

SELECT @xml

GO
/*
	Создать хранимую процедуру, возвращающую таблицу, заполненную
	из xml переменной представленного вида. Вызвать эту процедуру
	для заполненной на первом шаге переменной.
*/
CREATE PROCEDURE dbo.ReadFromXML
@xml XML
AS
	SELECT	AddressID = xmlNode.value('@ID', 'INT'),
			City = xmlNode.value('City[1]', 'NVARCHAR(30)'),
			StateProvinceID = xmlNode.value('Province[1]/@ID', 'INT'),
			CountryRegionCode = xmlNode.value('Province[1]/Region[1]', 'NVARCHAR(3)')
	FROM	@xml.nodes('/Addresses/Address') AS xml(xmlNode)
GO

EXECUTE dbo.ReadFromXML @xml