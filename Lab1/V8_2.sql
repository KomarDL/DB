USE AdventureWorks2012
GO

/* 
	Вывести на экран холостых сотрудников, которые 
	родились раньше 1960 года (включая 1960 год).
*/
SELECT 	[BusinessEntityID],
		[BirthDate],
		[MaritalStatus],
		[Gender],
		[HireDate]
FROM 	HumanResources.Employee
WHERE 	[MaritalStatus] = CAST('S' as NCHAR) AND 
		[BirthDate] < CAST('1961-01-01' as DATE)
		--Не понял почему конверт не сработа, а каст сработал
		--CONVERT(DATE, '1961-01-01', 'ISO8601')
		
/*
	Вывести на экран сотрудников, работающих на позиции
	‘Design Engineer’, отсортированных в порядке убывания 
	принятия их на работу.
*/
SELECT 	[BusinessEntityID],
		[JobTitle],
		[BirthDate],
		[Gender],
		[HireDate]
FROM 	HumanResources.Employee 
WHERE 	[JobTitle] = 'Design Engineer'
ORDER BY [HireDate] DESC

/*
	Вывести на экран количество лет, отработанных каждым 
	сотрудником отделе ‘Engineering’ ([DepartmentID] = 1). 
	Если поле EndDate = NULL это значит, что сотрудник 
	работает в отделе по настоящее время.
*/
SELECT 	[BusinessEntityID],
		[DepartmentID],
		[StartDate],
		[EndDate],
		DATEDIFF(year, [StartDate], COALESCE([EndDate], GETDATE())) as [YearsWorked]
FROM 	HumanResources.EmployeeDepartmentHistory