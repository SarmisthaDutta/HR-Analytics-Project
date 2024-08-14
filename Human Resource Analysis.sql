CREATE DATABASE hr_analytics_project;
USE hr_analytics_project;
SHOW TABLES;

-- If the table name is found, use it in your SELECT query
SELECT * 
FROM `human resources`;

ALTER TABLE `human resources`
CHANGE COLUMN ï»¿id EmployeeID VARCHAR(20) NULL;

DESCRIBE `human resources`

SET sql_safe_updates = 0;

-- CHANGE BITHDATE AND HIRE_DATE FORMET AND DATETYPE

UPDATE `human resources`
SET birthdate = CASE
    WHEN birthdate LIKE '%/%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE `human resources`
MODIFY COLUMN birthdate DATE;

UPDATE `human resources`
SET hire_date = CASE
    WHEN hire_date LIKE '%/%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE `human resources`
MODIFY COLUMN hire_date DATE;

-- change the date formet and datetype for termdate

UPDATE `human resources`
SET termdate = DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

UPDATE `human resources`
SET termdate = NULL
WHERE termdate = '';

ALTER TABLE `human resources`
MODIFY COLUMN termdate datetime;

-- CREATE AGE COLUMN

ALTER TABLE `human resources`
ADD COLUMN AGE INT;

SET SQL_SAFE_UPDATES = 0;

UPDATE `human resources`
SET age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE());

SET SQL_SAFE_UPDATES = 1;  -- Re-enable safe updates





SELECT *
FROM `human resources`

-- 1. How many employees are currently employed in each department?

SELECT DEPARTMENT, count(*) AS Employee_count
FROM `human resources`
WHERE termdate IS NULL
GROUP BY department;

-- 2. What is the average age of employees in each department?

SELECT department, AVG(age) AS Average_age
FROM `human resources`
GROUP BY department;

-- 3.What are the hiring trends for the last 10 years?
SELECT 
    YEAR(hire_date) AS hire_year, 
    COUNT(*) AS hires
FROM 
    `human resources`
WHERE 
    hire_date >= DATE_SUB(CURDATE(), INTERVAL 10 YEAR)
GROUP BY 
    YEAR(hire_date)
ORDER BY 
    hire_year;

-- 4.What is the average age and tenure of employees by job title?
SELECT 
    jobtitle, 
    AVG(AGE) AS average_age,
    AVG(DATEDIFF(COALESCE(termdate, CURDATE()), hire_date)) AS average_tenure_days
FROM 
    `human resources`
GROUP BY 
    jobtitle
ORDER BY 
    average_age DESC, average_tenure_days DESC;

-- 5. What is the gender distribution within each department?
SELECT 
    department, 
    gender, 
    jobtitle,
    COUNT(*) AS gender_count
FROM 
    `human resources`
WHERE termdate IS NOT NULL
GROUP BY 
    department,  gender, jobtitle
ORDER BY 
    department, gender_count, jobtitle;

-- 6. What is the distribution of employees' tenure?
SELECT 
    CASE 
        WHEN DATEDIFF(COALESCE(termdate, CURDATE()), hire_date) <= 365 THEN '0-1 years'
        WHEN DATEDIFF(COALESCE(termdate, CURDATE()), hire_date) <= 3*365 THEN '1-3 years'
        WHEN DATEDIFF(COALESCE(termdate, CURDATE()), hire_date) <= 5*365 THEN '3-5 years'
        ELSE '5+ years'
    END AS tenure_range,
    COUNT(*) AS employee_count
FROM 
    `human resources`
GROUP BY 
    tenure_range
ORDER BY 
    tenure_range;
    
-- 7. What is the average tenure of employees by department and location?
SELECT 
    department, 
    location, 
    AVG(DATEDIFF(COALESCE(termdate, CURDATE()), hire_date)) AS average_tenure_days
FROM 
    `human resources`
GROUP BY 
    department, 
    location
ORDER BY 
    average_tenure_days DESC;
    
-- 8. Which departments have the highest termination rates?
SELECT 
    department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN termdate IS NOT NULL THEN 1 ELSE 0 END) AS terminations,
    (SUM(CASE WHEN termdate IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS termination_rate
FROM 
    `human resources`
GROUP BY 
    department
ORDER BY 
    termination_rate DESC;

-- 9.
SELECT location_state,
    COUNT(*) AS employee_location_state
FROM 
    `human resources`
WHERE 
    termdate IS NULL
GROUP BY 
    location_state;

--- 

SELECT COUNT(*) AS active_employee_count
FROM `human resources`
WHERE termdate IS NULL;


-- 10. COMPANY EMPLOYEE CHANGE OVER THE YEAR BASIS ON HIRE AND TERMINATION
SELECT 
    year,
    hires,
    terminations,
    (hires - terminations) AS net_change,
    (terminations / hires) * 100 AS change_percent
FROM (
    SELECT 
        YEAR(hire_date) AS year,
        COUNT(*) AS hires,
        SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
    FROM 
        `human resources`
    GROUP BY 
        YEAR(hire_date)
) AS subquery
ORDER BY 
    year;

-- Terination and dire date breakdown by gender wise

SELECT
      gender,
      total_hires,
      total_terminations,
      Round((total_terminations/total_hires)*100,2) AS termination_rate
      FROM(
           SELECT gender,
           COUNT(*) AS total_hires,
           COUNT( CASE
                  WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 END) AS total_terminations
		   FROM `human resources`
           GROUP BY gender) AS subquery
           GROUP BY gender
           
-- Age

SELECT age,
      total_hires,
      total_terminations,
      Round((total_terminations/total_hires)*100,2) AS termination_rate
      FROM(
           SELECT age,
           COUNT(*) AS total_hires,
           COUNT( CASE
                  WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 END) AS total_terminations
		   FROM `human resources`
           GROUP BY age) AS subquery
           GROUP BY age
	  ORDER BY age
      
-- DEPARTMENT

SELECT
      department,
      total_hires,
      total_terminations,
      Round((total_terminations/total_hires)*100,2) AS termination_rate
      FROM(
           SELECT department,
           COUNT(*) AS total_hires,
           COUNT( CASE
                  WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 END) AS total_terminations
		   FROM `human resources`
           GROUP BY department) AS subquery
           GROUP BY department
	  ORDER BY department

-- HR SUMMARY
-- 1. Total Headcount
SELECT COUNT(*) AS total_headcount
FROM `human resources`
WHERE termdate IS NULL;

-- Headcount by Gender

SELECT 
    gender, 
    COUNT(*) AS gender_count
FROM 
    `human resources`
WHERE termdate IS NULL
GROUP BY 
    gender;

-- Total New Hires in the Last Year
SELECT 
    SELECT 
    COUNT(*) AS hires_2020
FROM 
    `human resources`
WHERE 
    YEAR(hire_date) = 2020;
    
-- Total Terminations in the Last Year
SELECT 
    COUNT(*) AS terminations_last_year
FROM 
    `human resources`
WHERE 
    termdate IS NOT NULL 
    AND termdate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);
    
-- Average Tenure
SELECT 
    AVG(DATEDIFF(COALESCE(termdate, CURDATE()), hire_date) / 365.25) AS average_tenure_years
FROM 
    `human resources`
WHERE 
    termdate IS NULL;
    
-- Average Age of Employees
SELECT 
    AVG(age) AS average_age
FROM 
    `human resources`
WHERE termdate IS NULL;

-- Page 1 - Employee Demographics and Distribution
-- Employee Count by Department
SELECT DEPARTMENT, count(*) AS Employee_count
FROM `human resources`
WHERE termdate IS NULL
GROUP BY department;

-- Average Age of Employees by Department
SELECT department, AVG(age) AS Average_age
FROM `human resources`
GROUP BY department;

-- Gender Distribution within Each Department
SELECT 
    department, 
    gender, 
    COUNT(*) AS gender_count
FROM 
    `human resources`
WHERE termdate IS NOT NULL
GROUP BY 
    department, gender
ORDER BY 
    department, gender_count;

-- Employee Distribution by Location
SELECT location_state,
    COUNT(*) AS employee_location_state
FROM 
    `human resources`
WHERE 
    termdate IS NULL
GROUP BY 
    location_state;

-- PAGE 2 -- Employee Tenure and Age Analysis
-- Employee count by age gruop and tenure

SELECT 
    CASE 
        WHEN age < 25 THEN 'Under 25'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65 and above'
    END AS age_group,
    COUNT(*) AS employee_count,
    AVG(DATEDIFF(COALESCE(termdate, CURDATE()), hire_date) / 365.25) AS average_tenure_years
FROM 
    `human resources`
GROUP BY 
    age_group
ORDER BY 
    age_group;

-- Distribution of Employees' Tenure
SELECT 
    CASE 
        WHEN DATEDIFF(COALESCE(termdate, CURDATE()), hire_date) <= 365 THEN '0-1 years'
        WHEN DATEDIFF(COALESCE(termdate, CURDATE()), hire_date) <= 3*365 THEN '1-3 years'
        WHEN DATEDIFF(COALESCE(termdate, CURDATE()), hire_date) <= 5*365 THEN '3-5 years'
        ELSE '5+ years'
    END AS tenure_range,
    COUNT(*) AS employee_count
FROM 
    `human resources`
GROUP BY 
    tenure_range
ORDER BY 
    tenure_range;

-- Average Tenure of Employees by Department and Location
SELECT 
    department, 
    location, 
    AVG(DATEDIFF(COALESCE(termdate, CURDATE()), hire_date) / 365.25) AS average_tenure_years
FROM 
    `human resources`
GROUP BY 
    department, 
    location
ORDER BY 
    average_tenure_years DESC;

-- Page 3 -- Hiring and Termination Trends
-- Hiring Trends for the Last 10 Years
SELECT 
    YEAR(hire_date) AS hire_year, 
    COUNT(*) AS hires
FROM 
    `human resources`
WHERE 
    hire_date >= DATE_SUB(CURDATE(), INTERVAL 10 YEAR)
GROUP BY 
    YEAR(hire_date)
ORDER BY 
    hire_year;
    
-- Company Employee Change Over the Years Based on Hire and Termination

SELECT 
    year,
    hires,
    terminations,
    (hires - terminations) AS net_change,
    (terminations / hires) * 100 AS change_percent
FROM (
    SELECT 
        YEAR(hire_date) AS year,
        COUNT(*) AS hires,
        SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
    FROM 
        `human resources`
    GROUP BY 
        YEAR(hire_date)
) AS subquery
ORDER BY 
    year;

-- Page 4: Termination Analysis
-- 1. Termination Rates by Gender

SELECT
      gender,
      total_hires,
      total_terminations,
      ROUND((total_terminations / total_hires) * 100, 2) AS termination_rate
FROM (
    SELECT 
        gender,
        COUNT(*) AS total_hires,
        COUNT(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 END) AS total_terminations
    FROM 
        `human resources`
    GROUP BY 
        gender
) AS subquery
GROUP BY 
    gender;

-- 2. Termination Rates by Age
SELECT age,
      total_hires,
      total_terminations,
      ROUND((total_terminations / total_hires) * 100, 2) AS termination_rate
FROM (
    SELECT 
        age,
        COUNT(*) AS total_hires,
        COUNT(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 END) AS total_terminations
    FROM 
        `human resources`
    GROUP BY 
        age
) AS subquery
GROUP BY 
    age
ORDER BY 
    age;

-- 3. Termination Rates by Department
SELECT
      department,
      total_hires,
      total_terminations,
      ROUND((total_terminations / total_hires) * 100, 2) AS termination_rate
FROM (
    SELECT 
        department,
        COUNT(*) AS total_hires,
        COUNT(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 END) AS total_terminations
    FROM 
        `human resources`
    GROUP BY 
        department
) AS subquery
GROUP BY 
    department
ORDER BY 
    department;

-- 4. Year wise Termination Rates
SELECT 
    department,
    YEAR(termdate) AS termination_year,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN termdate IS NOT NULL THEN 1 ELSE 0 END) AS terminations,
    (SUM(CASE WHEN termdate IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS termination_rate
FROM 
    `human resources`
GROUP BY 
    department,
    YEAR(termdate)
ORDER BY 
    termination_year DESC,
    department;










        
    



