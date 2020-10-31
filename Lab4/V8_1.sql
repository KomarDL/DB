USE AdventureWorks2012
GO

--drop table Person.CountryRegionHst
drop trigger Person.CountryRegionAfterDelete
/*
	a) Создайте таблицу Person.CountryRegionHst, которая будет хранить
	информацию об изменениях в таблице Person.CountryRegion
*/
CREATE TABLE Person.CountryRegionHst(
	ID INT IDENTITY(1, 1) PRIMARY KEY,
	Action NVARCHAR(6) NOT NULL,
	ModifiedDate DATETIME NOT NULL CONSTRAINT Default_ModifiedDate DEFAULT GETDATE(),
	SourceID NVARCHAR(3) NOT NULL,
	UserName NVARCHAR(100) NOT NULL CONSTRAINT Default_UserName DEFAULT USER_NAME(),

	CONSTRAINT OnlyActions CHECK(Action IN ('INSERT', 'UPDATE', 'DELETE'))
);

/*
	b) Создайте три AFTER триггера для трех операций INSERT, UPDATE, DELETE
	 для таблицы Person.CountryRegion. Каждый триггер должен заполнять таблицу
	  Person.CountryRegionHst с указанием типа операции в поле Action.
*/
USE AdventureWorks2012	--почему если это не сделать бьёт ошибку
GO						--'CREATE TRIGGER' must be the first statement in a query batch
CREATE TRIGGER Person.CountryRegionAfterInsert ON Person.CountryRegion
AFTER INSERT
AS 
INSERT INTO Person.CountryRegionHst  (Action, SourceID)
SELECT	'INSERT',
		inserted.CountryRegionCode
FROM	inserted
GO		--а без этого GO почему-то ругается на следующую строку

USE AdventureWorks2012	
GO						
CREATE TRIGGER Person.CountryRegionAfterUpdate ON Person.CountryRegion
AFTER UPDATE
AS 
INSERT INTO Person.CountryRegionHst  (Action, SourceID)
SELECT	'UPDATE',
		inserted.CountryRegionCode
FROM	inserted
GO

USE AdventureWorks2012	
GO						
CREATE TRIGGER Person.CountryRegionAfterDelete ON Person.CountryRegion
AFTER DELETE
AS 
INSERT INTO Person.CountryRegionHst  (Action, SourceID)
SELECT	'DELETE',
		deleted.CountryRegionCode
FROM	deleted
GO

/*
	c) Создайте представление VIEW, отображающее все поля таблицы Person.CountryRegion. 
	Сделайте невозможным просмотр исходного кода представления.
*/
CREATE VIEW Person.EncryptedView
WITH ENCRYPTION
AS 
SELECT	*
FROM	Person.CountryRegion
GO
/*
	d) Вставьте новую строку в Person.CountryRegion через представление. 
	Обновите вставленную строку. Удалите вставленную строку. Убедитесь, 
	что все три операции отображены в Person.CountryRegionHst.
*/
INSERT INTO Person.EncryptedView (
	CountryRegionCode,
	Name,
	ModifiedDate)
VALUES (
	'ABC',
	'Komar',
	GETDATE()
)
SELECT * FROM Person.CountryRegion

UPDATE	Person.EncryptedView
SET		Name = 'DMITRY',
		ModifiedDate = GETDATE()
WHERE	CountryRegionCode = 'ABC'
SELECT * FROM Person.CountryRegion

DELETE FROM Person.EncryptedView
WHERE CountryRegionCode = 'ABC'
SELECT * FROM Person.CountryRegion