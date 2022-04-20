-- Exploring Covid 19 Data with SQL Server

-- Skill Used : Aggregate Functions, Joins, Subqueries, CTE, windows Function

USE PortofolioProject

-- Let's see the tables
SELECT *
FROM cases
ORDER BY location, date

SELECT *
FROM vaccinations
ORDER BY location, date

SELECT *
FROM demographic
ORDER BY location



-- daily number of new_cases for each country
SELECT location, date, new_cases
FROM cases
ORDER BY location, date

 
 -- Top 10 country with higest total_cases
SELECT TOP 10 location, MAX(total_cases) as total_cases
FROM cases
GROUP BY location
ORDER BY MAX(total_cases) DESC


-- Top 10 country with higest total_deaths
SELECT TOP 10 location, MAX(total_deaths) as total_deaths
FROM cases
GROUP BY location
ORDER BY MAX(total_deaths) DESC


-- Order country by death rate (display only data where total_deaths > 100000)
SELECT  location, 
		MAX(total_cases) AS cases, 
		MAX (total_deaths) AS deaths, 
		ROUND((MAX(total_deaths)/MAX(total_cases))*100, 2) AS death_rate
FROM cases
GROUP BY location
HAVING MAX(total_deaths) > 100000
ORDER BY death_rate DESC


-- See last data of total cases, total deaths, new_cases, new_deaths for all countries
SELECT  location,
		date,
		total_cases,
		total_deaths,
		new_cases,
		new_deaths
FROM
(SELECT  location,
		date,
		total_cases,
		total_deaths,
		new_cases,
		new_deaths,
		ROW_NUMBER() OVER(PARTITION BY location ORDER BY date DESC) AS count_from_last_day
FROM cases) AS sub
WHERE count_from_last_day = 1
ORDER BY date DESC


-- total vaccinations in Top 10 country with higest total_cases
WITH top_cases(location, total_deaths) AS(
	SELECT TOP 10 location, MAX(total_cases) as total_cases
	FROM cases
	GROUP BY location
	ORDER BY MAX(total_cases) DESC
)
SELECT location, MAX(total_vaccinations) AS total_vaccinations
FROM vaccinations
GROUP BY location
HAVING location IN (SELECT location FROM top_cases)


-- Shows per million of population that has received vaccinations
SELECT v.date, v.location, v.new_vaccinations, 
		SUM(v.new_vaccinations) OVER(PARTITION BY v.location, v.date) AS CumulativeVaccinations,
		ROUND((v.new_vaccinations/d.population *1000000),3) AS dailyVaccinaationPerMillions
FROM vaccinations AS v
LEFT JOIN demographic AS d
ON v.location = d.location



/*
COVID 19 in Indonesia
*/

-- Daily cases in Indonesia
SELECT date, new_cases, total_cases, new_deaths, total_deaths
FROM cases
WHERE location = 'Indonesia'
ORDER BY date

-- Summary of covid  19 in Indonesia
SELECT  MAX(total_cases) AS ConfimedCases, 
		MAX(total_deaths) AS ConfimedDeaths, 
		MAX(total_vaccinations) AS ConfirmedVaccinations
FROM cases AS c
INNER JOIN vaccinations AS v
ON c.date = v.date AND c.location = v.location
WHERE c.location = 'Indonesia'


-- Date with the highest new cases in Indonesia
SELECT date, new_cases
FROM cases
WHERE location = 'Indonesia' AND
	  new_cases = (	SELECT MAX(new_cases)
					FROM cases
					WHERE location = 'Indonesia')


-- Date with the highest new deaths in Indonesia
SELECT date, new_deaths
FROM cases
WHERE location = 'Indonesia' AND
	  new_deaths = (
			SELECT MAX(new_deaths)
			FROM cases
			WHERE location = 'Indonesia')


-- 10 Date with highest new cases in Indonesia
WITH dailyCasesIndo(date, new_cases, new_deaths) AS (
	SELECT date, new_cases, new_deaths
	FROM cases
	WHERE location = 'Indonesia'
)
SELECT TOP 20 date, new_cases,
		RANK() OVER(ORDER BY new_cases DESC) AS daily_new_cases_pos
FROM dailyCasesIndo
ORDER BY daily_new_cases_pos