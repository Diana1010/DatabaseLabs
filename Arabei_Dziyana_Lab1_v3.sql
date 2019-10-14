-- 3 Вариант
USE adventureworks2012;
GO 

-- Задание 1
SELECT departmentid, 
       name 
FROM   humanresources.department 
WHERE  name LIKE 'P%' 

-- Задание 2
SELECT businessentityid, 
       jobtitle, 
       gender, 
       vacationhours, 
       sickleavehours 
FROM   humanresources.employee 
WHERE  vacationhours BETWEEN 10 AND    13 

-- Задание 3
SELECT   businessentityid, 
         jobtitle, 
         gender, 
         birthdate, 
         hiredate 
FROM     humanresources.employee 
WHERE    MONTH(hiredate) = 7 
AND      DAY(hiredate) = 1 
ORDER BY businessentityid asc offset (3) ROWS 
FETCH next (5) ROWS only