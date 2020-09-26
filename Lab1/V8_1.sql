CREATE DATABASE Komar_Dmitry;

USE Komar_Dmitry;
GO

CREATE SCHEMA sales;
GO

CREATE SCHEMA persons;
GO

CREATE TABLE sales.Orders (OrderNum INT NULL);

BACKUP DATABASE Komar_Dmitry
TO DISK = 'O:\Projects\Term_7\DB\Lab1\Komar_Dmitry.bak';

USE master
GO 

DROP DATABASE Komar_Dmitry;

RESTORE DATABASE Komar_Dmitry
FROM DISK = 'O:\Projects\Term_7\DB\Lab1\Komar_Dmitry.bak';

USE Komar_Dmitry
GO