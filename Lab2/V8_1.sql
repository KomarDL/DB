USE AdventureWorks2012
GO

/*
	Вывести на экран список сотрудников которые 
	подавали резюме при трудоустройстве.
*/
SELECT		Employee.BusinessEntityID,
			[OrganizationLevel],
			[JobTitle],
			[JobCandidateID],
			[Resume]
FROM		HumanResources.Employee
INNER JOIN	HumanResources.JobCandidate
ON			Employee.BusinessEntityID = JobCandidate.BusinessEntityID

/*
	Вывести на экран названия отделов, в которых
	работает более 10-ти сотрудников
*/
SELECT		Department.DepartmentID,
			[Name],
			COUNT(Department.DepartmentID) as [EmpCount]
FROM		HumanResources.Department
JOIN		HumanResources.EmployeeDepartmentHistory
ON			EmployeeDepartmentHistory.DepartmentID = Department.DepartmentID
GROUP BY	Department.DepartmentID, [Name]
HAVING		COUNT(Department.DepartmentID) > 10

/*
	Вывести на экран накопительную сумму часов отпуска по причине 
	болезни (SickLeaveHours) в рамках каждого отдела. 
	Сумма должна накапливаться по мере трудоустройства сотрудников (HireDate).
*/
SELECT		Department.Name,
			Employee.HireDate,
			Employee.SickLeaveHours,
			SUM(Employee.SickLeaveHours) OVER (PARTITION BY Department.Name 
											   ORDER BY Employee.HireDate ASC
											   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [AccumulativeSum]
			--Долго делал это задание. А есть вариант для [AccumulativeSum] короче моего? Покажите
FROM		HumanResources.EmployeeDepartmentHistory
JOIN		HumanResources.Employee   ON Employee.BusinessEntityID = EmployeeDepartmentHistory.DepartmentID
JOIN		HumanResources.Department ON Department.DepartmentID = EmployeeDepartmentHistory.DepartmentID
WHERE		EmployeeDepartmentHistory.EndDate IS NULL --Убрал отделы в которых люди работали раньше
