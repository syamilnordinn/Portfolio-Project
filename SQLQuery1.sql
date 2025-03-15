
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths
-- likelihood of u dying if u have covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage 
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%States  %'
ORDER BY 1,2

--Total cases vs population
SELECT location, date, total_cases, Population, (total_cases/Population)*100 as deathpercentage 
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%States%'
ORDER BY 1,2

--Countries with the highest infection rate compared to other countries
SELECT location, MAX(total_cases), Population, (MAX(total_cases)/Population)*100 as PopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PopulationInfected DESC

--People with highest death count per population
 


--total death pecentage per countries
SELECT location, Population, SUM(cast(total_deaths as int)) AS totalppldied, (SUM(cast(total_deaths as int))/Population)*100 as TotalDeath
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY TotalDeath DESC

-- LETS BREAK THINGS DOWN BY CONTINENT
SELECT location, MAX(cast(total_deaths as int)) AS ttldeathcount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY ttldeathcount DESC

-- Global Numbers

SELECT date, Sum(new_cases) as ttlcases, SUM(CAST(new_deaths AS int)) as ttldeath, SUM(CAST(new_deaths AS int))*100/SUM(new_cases) AS deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--total population vs vaccination

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int))OVER(PARTITION BY dea.continent, dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent IS NOT NULL

--USE CTE

WITH PopvsVac AS
(SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int))OVER(PARTITION BY dea.continent, dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent IS NOT NULL)


SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac
ORDER BY 1,2,3;

--Creating View 
Create View PercentPopulationVaccinated AS
(SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int))OVER(PARTITION BY dea.continent, dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent IS NOT NULL)

SELECT *
FROM PercentPopulationVaccinated;