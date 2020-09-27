USE AdventureWorks2012
GO

DROP TABLE dbo.Address; 

/*
	a) создайте таблицу dbo.Address с такой же структурой
	как Person.Address, кроме полей geography, uniqueidentifier,
	не включая индексы, ограничения и триггеры;
*/
create table dbo.Address (
	AddressID		int,
	AddressLine1	nvarchar(64),
	AddressLine2	nvarchar(64),
	City			nvarchar(32),
	StateProvinceID int,
	PostalCode		nvarchar(16),
	ModifiedDate	datetime,
);
--пытался ещё вот так исключить поля, но EXCEPT работает с данными, а не со структурой таблицы
--SELECT * INTO dbo.Address 
--FROM Person.Address
--EXCEPT
--SELECT sc.name
--FROM 
--    sys.columns AS sc 
--    join sys.types AS st ON sc.user_type_id = st.user_type_id
--WHERE	sc.object_id = object_id('Person.Address') AND
--		(st.name = CAST('geography' AS sysname) OR
--		st.name = CAST('uniqueidentifier' AS sysname))

/*
	b) используя инструкцию ALTER TABLE, добавьте в таблицу dbo.Address
	новое поле ID с типом данных INT, имеющее свойство identity с 
	начальным значением 1 и приращением 1. 
	создайте для нового поля ID ограничение UNIQUE;
*/
ALTER TABLE dbo.Address
ADD ID int IDENTITY(1, 1) UNIQUE;

/*
	c) используя инструкцию ALTER TABLE, создайте для 
	таблицы dbo.Address ограничение для поля StateProvinceID,
	чтобы заполнить его можно было только нечетными числами;
*/  
ALTER TABLE dbo.Address 
ADD CONSTRAINT Odd check((StateProvinceID % 2) = 1);

/*
	d) используя инструкцию ALTER TABLE, создайте для таблицы 
	dbo.Address ограничение DEFAULT для поля AddressLine2, 
	задайте значение по умолчанию СUnknownТ;
*/
ALTER TABLE dbo.Address 
ADD CONSTRAINT Unknown
DEFAULT 'Unknown' FOR AddressLine2

/*
	e) заполните новую таблицу данными из Person.Address. 
	выберите для вставки только те адреса, где значение поля Name
	из таблицы CountryRegion начинается на букву а. также исключите данные,
	где StateProvinceID содержит четные числа. заполните поле AddressLine2 значениями по умолчанию;
*/
INSERT INTO dbo.Address 
		(Address.AddressID,
		Address.AddressLine1,	
		Address.City,
		Address.StateProvinceID,
		Address.PostalCode,
		Address.ModifiedDate)
SELECT	Address.AddressID,
		Address.AddressLine1,	
		Address.City,
		Address.StateProvinceID,
		Address.PostalCode,
		Address.ModifiedDate 
FROM	Person.Address 
JOIN	Person.StateProvince
ON		Person.Address.StateProvinceID = Person.StateProvince.StateProvinceID 
JOIN	Person.CountryRegion
ON		Person.StateProvince.CountryRegionCode = Person.CountryRegion.CountryRegionCode
WHERE   Person.CountryRegion.Name LIKE 'a%' AND
		(Person.Address.StateProvinceID % 2) = 1

SELECT	*
FROM	dbo.Address

/*
	f) измените поле AddressLine2, запретив вставку null значений.
*/
ALTER TABLE dbo.Address 
ALTER COLUMN AddressLine2 nvarchar(64) not null;