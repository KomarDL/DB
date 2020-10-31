use AdventureWorks2012
GO

/*
	a) добавьте в таблицу dbo.Address поле PersonName 
	типа nvarchar размерностью 100 символов;
*/
ALTER TABLE dbo.Address ADD PersonName VARCHAR(100)

/*
	b) объявите табличную переменную с такой же структурой 
	как dbo.Address и заполните ее данными из dbo.Address, 
	где StateProvinceID = 77. Поле AddressLine2 заполните 
	значениями из CountryRegionCode таблицы Person.CountryRegion, 
	Name таблицы Person.StateProvince и City из Address. Разделите значения запятыми;
*/
DECLARE @TableVar TABLE(AddressID int NULL,
						AddressLine1 nvarchar(64) NULL,
						AddressLine2 nvarchar(64) NOT NULL,
						City nvarchar(32) NULL,
						StateProvinceID int NULL,
						PostalCode nvarchar(15) NULL,
						ModifiedData datetime NULL,
						ID int identity(1,1) unique not null,
						PersonName varchar(100) NULL);

INSERT INTO @TableVar 
		(AddressID,
		 AddressLine1,
		 AddressLine2,	
		 City,
		 StateProvinceID,
		 PostalCode,
		 ModifiedData)
SELECT	AddressID,
		AddressLine1,	
		(SELECT CntrRgn.CountryRegionCode + ', ' + SttPrvnc.Name + ', ' + Addr.City
		 FROM	Person.CountryRegion AS CntrRgn 
		 JOIN	Person.StateProvince AS SttPrvnc 
		 ON		CntrRgn.CountryRegionCode = SttPrvnc.CountryRegionCode 
		 JOIN	Person.Address AS PAddr
		 ON     SttPrvnc.StateProvinceID = PAddr.StateProvinceID
		 WHERE	PAddr.AddressID = Addr.AddressID),
		City,
		StateProvinceID,
		PostalCode,
		ModifiedDate
FROM	dbo.Address AS Addr
WHERE   StateProvinceID = 77;
SELECT * FROM @TableVar --проверка 

/* 
	c) обновите поле AddressLine2 в dbo.Address данными из 
	табличной переменной. Также обновите данные в поле PersonName 
	данными из Person.Person, соединив значения полей FirstName и LastName;
*/
UPDATE	dbo.Address
SET		AddressLine2 = tmp.AddressLine2 --почему ругается если использовать
										-- @TableVar без псевдонима
FROM	@TableVar AS tmp; 

UPDATE	dbo.Address 
SET		PersonName = PPrsn.FirstName + ' ' + PPrsn.LastName 
FROM	Person.Person AS PPrsn 
JOIN	Person.BusinessEntityAddress AS PBisness 
ON		PBisness.BusinessEntityID = PPrsn.BusinessEntityID 
WHERE	PBisness.AddressID = dbo.Address.AddressID;

/*
	d) удалите данные из dbo.Address, которые относятся к типу 
	‘Main Office’ из таблицы Person.AddressType;
*/
DELETE	dbo.Address 
FROM	dbo.Address AS Addr 
JOIN	Person.BusinessEntityAddress AS PBisness 
ON		Addr.AddressID = PBisness.AddressID 
JOIN	Person.AddressType AS AddrT
ON		PBisness .AddressTypeID = AddrT.AddressTypeID
WHERE	AddrT.Name = 'Main Office';

/*
	e) удалите поле PersonName из таблицы, удалите все 
	созданные ограничения и значения по умолчанию;
*/
ALTER TABLE dbo.Address DROP COLUMN PersonName;
ALTER TABLE dbo.Address DROP CONSTRAINT Odd
ALTER TABLE dbo.Address DROP CONSTRAINT Unknown
ALTER TABLE dbo.Address DROP CONSTRAINT UQ__Address__3214EC26388ACA75

SELECT *
FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Address';

/*
	f) удалите таблицу dbo.Address.
*/
drop table dbo.Address











