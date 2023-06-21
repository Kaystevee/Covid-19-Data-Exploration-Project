/*
Covid 19 Data Exploration 

Skills used for the project: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- CovidDeath table presents statistics on the global population affected by COVID-19, including the number of confirmed cases and recorded deaths

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 3,4;


/*CovidVaccinations table illustrates the worldwide distribution and administration of COVID-19 vaccines, highlighting the progress made in 
vaccinating populations around the globe. */

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent is not null 
ORDER BY 3,4;


--Select Data that will be using for this project

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null 
ORDER BY 1, 2;

--Total cases vs Total Deaths
--Showing probability of death if you contract COVID-19 in your country 

SELECT Location, CONVERT(VARCHAR(10), Date, 120) AS Date, total_cases, total_deaths, 
       ROUND((CONVERT(float,total_deaths) / CONVERT(float,total_cases)) * 100, 2) AS Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%'
AND continent is not null 
ORDER BY  1, 2;


-- Total cases vs population
-- showing what percentage of the population who got COVID-19

SELECT Location, CONVERT(VARCHAR(10), Date, 120) AS Date, population,total_cases, total_deaths, 
       ROUND((total_cases/population) * 100, 2) AS PercentagePopulationInfested
FROM PortfolioProject..CovidDeaths
Where continent is not null 
ORDER BY 1, 2;


--Showing Countries with Highest Infection Rate compared to Population 


SELECT Location, population, MAX(total_cases) AS HighestCovidCount,
       ROUND(MAX(total_cases/population) * 100, 2) AS PercentagePopulationInfested
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
ORDER BY 4 DESC;


--Showing Countries with Highest Death count per Population


SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--Breaking down by Continent
--Showing Continent with Highest Death Count per Population


SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
  AND location NOT IN ('high income', 'world','European Union', 'upper middle income', 'lower middle income', 'low income')
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Global Numbers


SELECT  SUM(new_cases) AS 'TotalNewCases', SUM(new_deaths) AS 'TotalNewDeaths',
       ROUND(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0), 2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE new_cases IS NOT NULL
ORDER BY 1, 2;


--Looking at Total Population Vs Vaccinations

SELECT CovDt.continent, CovDt.location, CONVERT(VARCHAR(10), CovDt.Date, 120) AS Date, CovDt.population, CovVc.new_vaccinations,
	SUM(CONVERT(float, CovVC.new_vaccinations )) OVER (PARTITION BY CovDt.location ORDER BY CovDt.population, CovDt.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS CovDt
JOIN PortfolioProject..CovidVaccinations AS CovVc
	ON CovDt.location = CovVc.location
	AND CovDt.date = CovVc.date
WHERE CovDt.continent IS NOT NULL
ORDER BY 2,3;


--Using CTE


WITH PopVsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS(
SELECT CovDt.continent, CovDt.location, CONVERT(VARCHAR(10), CovDt.Date, 120) AS Date, CovDt.population, CovVc.new_vaccinations,
	SUM(CONVERT(float, CovVC.new_vaccinations )) OVER (PARTITION BY CovDt.location ORDER BY CovDt.population, CovDt.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS CovDt
JOIN PortfolioProject..CovidVaccinations AS CovVc
	ON CovDt.location = CovVc.location
	AND CovDt.date = CovVc.date
WHERE CovDt.continent IS NOT NULL
)
SELECT *, ROUND((RollingPeopleVaccinated / population) * 100, 2) AS PercentageRollingPeopleVaccinated
FROM PopVsVac;



--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT CovDt.continent, CovDt.location, CONVERT(VARCHAR(10), CovDt.Date, 120) AS Date, CovDt.population, CovVc.new_vaccinations,
	SUM(CONVERT(float, CovVC.new_vaccinations )) OVER (PARTITION BY CovDt.location ORDER BY CovDt.population, CovDt.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS CovDt
JOIN PortfolioProject..CovidVaccinations AS CovVc
	ON CovDt.location = CovVc.location
	AND CovDt.date = CovVc.date


SELECT *, ROUND((RollingPeopleVaccinated / population) * 100, 2) PercentPopulationVaccinated
FROM #PercentPopulationVaccinated;


--Creating view to store data for later visualizations


--Showing Countries with Highest Infection Rate compared to Population 

CREATE VIEW PercentagePopulationInfested AS

SELECT Location, population, MAX(total_cases) AS HighestCovidCount,
       ROUND(MAX(total_cases/population) * 100, 2) AS PercentagePopulationInfested
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population;


--Showing Countries with Highest Death count per Population

CREATE VIEW TotalDeathCountCountries AS

SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location;

--Showing Total death count across various continent

CREATE VIEW TotalDeathCountContinent AS

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
  AND location NOT IN ('high income', 'world','European Union', 'upper middle income', 'lower middle income', 'low income')
GROUP BY location;


--Showing Total death count across the globe

CREATE VIEW TotalDeathGlobe AS

SELECT  SUM(new_cases) AS 'TotalNewCases', SUM(new_deaths) AS 'TotalNewDeaths',
       ROUND(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0), 2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE new_cases IS NOT NULL;



CREATE VIEW PercentPopulationVaccinated AS

SELECT CovDt.continent, CovDt.location, CONVERT(VARCHAR(10), CovDt.Date, 120) AS Date, CovDt.population, CovVc.new_vaccinations,
	SUM(CONVERT(float, CovVC.new_vaccinations )) OVER (PARTITION BY CovDt.location ORDER BY CovDt.population, CovDt.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS CovDt
JOIN PortfolioProject..CovidVaccinations AS CovVc
	ON CovDt.location = CovVc.location
	AND CovDt.date = CovVc.date
WHERE CovDt.continent IS NOT NULL;
