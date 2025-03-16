SELECT *
FROM PortfolioProject..CovidDeaths

SELECT *
FROM PortfolioProject..CovidVaccinations

--Find the highest daily new cases per million for each country and display the date it occurred.
SELECT location, date, ROUND(MAX(total_cases_per_million), 2) AS Highest_Case_Per_Million
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, date
ORDER BY Highest_Case_Per_Million DESC;

--Find the countries with the highest COVID-19 death rate (total deaths per total cases) and total cases more than 1 million.
SELECT location, SUM(total_cases) AS Ttl_Cases, SUM(CAST(total_deaths AS int)) AS Ttl_Death, SUM(CAST(total_deaths AS int))/SUM(total_cases)*100 AS Ttl_Death_Per_Cases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
HAVING SUM(total_cases) > 10000000
ORDER BY Ttl_Death_Per_Cases DESC;

--Calculate the 7-day moving average of new cases for the entire world(at least 7 days of data available)

SELECT date, new_cases, Moving_Avg_7Days
FROM (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY date) AS row_num, 
        date, 
        new_cases, 
        AVG(new_cases) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Moving_Avg_7Days
    FROM PortfolioProject..CovidDeaths
    WHERE location = 'World'
) AS x
WHERE row_num >= 6
ORDER BY date;

--Calculate the percentage of the population vaccinated per continent
SELECT dea.continent, SUM(CAST(vac.new_vaccinations as bigint)) *100/SUM(DISTINCT dea.population)
FROM PortfolioProject..CovidDeaths AS dea
	INNER JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent
ORDER BY dea.continent;

--OR

WITH x AS
(SELECT dea.continent, dea.location, population AS ttlpop, MAX(CAST(vac.total_vaccinations as bigint)) AS ttlvacloc
FROM PortfolioProject..CovidDeaths AS dea
	INNER JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.location, population)

SELECT continent, (SUM(ttlvacloc)/SUM(ttlpop))*100
FROM x
GROUP BY continent;

--Rank countries by speed of vaccination, based on how quickly they vaccinated their population.
--earliest date when a country reached at least 50% vaccinated.

SELECT *
FROM
(SELECT dea.location, dea.date, dea.population, vac.total_vaccinations, CAST(vac.total_vaccinations as bigint)/dea.population AS Percen, RANK()OVER(PARTITION BY dea.location ORDER BY dea.date) AS ranking
FROM PortfolioProject..CovidDeaths AS dea
	INNER JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND CAST(vac.total_vaccinations as bigint)/dea.population > 0.5) as x
WHERE ranking = 1
ORDER BY date;

--OR

SELECT location, MIN(date) as min_date
FROM
(SELECT dea.location, dea.date, dea.population, vac.total_vaccinations, CAST(vac.total_vaccinations as bigint)/dea.population AS percen
FROM PortfolioProject..CovidDeaths AS dea
	INNER JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND CAST(vac.total_vaccinations as bigint)/dea.population > 0.5) as y
GROUP BY location
ORDER BY min_date

--Find the acceleration of vaccinations (how much the daily vaccinations increased or decreased compared to the previous day).
SELECT date, new_vaccinations, LAG(new_vaccinations)OVER(ORDER BY date) AS prev_vac, new_vaccinations - LAG(CAST(new_vaccinations AS int))OVER(ORDER BY date) AS acceleration
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL AND location LIKE '%United States%';




