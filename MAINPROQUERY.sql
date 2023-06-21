/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 3,4


--Select Data that we will be using for this project

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null 
ORDER BY 1, 2;

--Total cases vs Total Deaths
--Showing probability od death if you contract COVID19 in your country

SELECT Location, CONVERT(VARCHAR(10), Date, 120) AS Date, total_cases, total_deaths, 
       ROUND((CONVERT(float,total_deaths) / CONVERT(float,total_cases)) * 100, 2) AS Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%'
AND continent is not null 
ORDER BY  1, 2;


-- Total cases vs population
-- shows what percentage of population got COVID

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

--GLOBAL NUMBRS


SELECT  SUM(new_cases) AS 'TotalNewCases', SUM(new_deaths) AS 'TotalNewDeaths',
       ROUND(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0), 2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE new_cases IS NOT NULL
--GROUP BY Date
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


--USE CTE


WITH PopVsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS(
SELECT CovDt.continent, CovDt.location, CONVERT(VARCHAR(10), CovDt.Date, 120) AS Date, CovDt.population, CovVc.new_vaccinations,
	SUM(CONVERT(float, CovVC.new_vaccinations )) OVER (PARTITION BY CovDt.location ORDER BY CovDt.population, CovDt.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS CovDt
JOIN PortfolioProject..CovidVaccinations AS CovVc
	ON CovDt.location = CovVc.location
	AND CovDt.date = CovVc.date
WHERE CovDt.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, ROUND((RollingPeopleVaccinated / population) * 100, 2)
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
--WHERE CovDt.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, ROUND((RollingPeopleVaccinated / population) * 100, 2)
FROM #PercentPopulationVaccinated;


--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS

SELECT CovDt.continent, CovDt.location, CONVERT(VARCHAR(10), CovDt.Date, 120) AS Date, CovDt.population, CovVc.new_vaccinations,
	SUM(CONVERT(float, CovVC.new_vaccinations )) OVER (PARTITION BY CovDt.location ORDER BY CovDt.population, CovDt.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS CovDt
JOIN PortfolioProject..CovidVaccinations AS CovVc
	ON CovDt.location = CovVc.location
	AND CovDt.date = CovVc.date
WHERE CovDt.continent IS NOT NULL
--ORDER BY 2,3