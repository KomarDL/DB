USE AdventureWorks2012
GO

/* 
	������� �� ����� �������� �����������, ������� 
	�������� ������ 1960 ���� (������� 1960 ���).
*/
SELECT 	[BusinessEntityID],
		[BirthDate],
		[MaritalStatus],
		[Gender],
		[HireDate]
FROM 	HumanResources.Employee
WHERE 	[MaritalStatus] = CAST('S' as NCHAR) AND 
		[BirthDate] < CAST('1961-01-01' as DATE)
		--�� ����� ������ ������� �� �������, � ���� ��������
		--CONVERT(DATE, '1961-01-01', 'ISO8601')
		
/*
	������� �� ����� �����������, ���������� �� �������
	�Design Engineer�, ��������������� � ������� �������� 
	�������� �� �� ������.
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
	������� �� ����� ���������� ���, ������������ ������ 
	����������� ������ �Engineering� ([DepartmentID] = 1). 
	���� ���� EndDate = NULL ��� ������, ��� ��������� 
	�������� � ������ �� ��������� �����.
*/
SELECT 	[BusinessEntityID],
		[DepartmentID],
		[StartDate],
		[EndDate],
		DATEDIFF(year, [StartDate], COALESCE([EndDate], GETDATE())) as [YearsWorked]
FROM 	HumanResources.EmployeeDepartmentHistory