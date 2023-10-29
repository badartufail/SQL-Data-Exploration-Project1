--Reference Video: https://www.youtube.com/watch?v=qfyynHBFOsM&list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f

/*
Data Exploration (Covid-19)

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;


--select *
--from PortfolioProject..CovidVaccinations
--order BY 3,4;


--Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


--DDL - Altering data type
ALTER TABLE PortfolioProject..CovidDeaths
    ALTER COLUMN total_cases float 
	ALTER COLUMN total_deaths float;


--Looking at Total cases vs Total Deaths
--Shows the likely hood of dying if you contarct covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%pakistan%'
	AND continent IS NOT NULL
ORDER BY 1,2;


--Looking at the Total Cases vs the Population
--shows the percentage of population that contracted Covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as Contraction_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%pakistan%'
	AND continent IS NOT NULL
ORDER BY 1,2;


--Looking at Countries with the highest infection rate compared to Population
SELECT location, Population, MAX(Total_cases) as highestInfectionCount, MAX((total_cases/population))*100 as Infection_Rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Infection_Rate DESC;


--Looking at Countries with the highest Death countr per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


--LETS EXPLORE STATS BY CONTINENT
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


--Global Numbers
--By date
SELECT date, SUM(new_cases) as total_cases, SUM (new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
group by date
HAVING SUM(new_cases) != 0
ORDER BY 1,2;


--Overall
SELECT SUM(new_cases) as total_cases, SUM (new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
HAVING SUM(new_cases) != 0
ORDER BY 1,2;


--DDL - Altering data type
ALTER TABLE PortfolioProject..CovidVaccinations
	ALTER COLUMN new_vaccinations float;


--Looking at Total Population vs Vaccinations
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingVaccinationTotal
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL and dea.location = 'Canada'
ORDER BY 2,3


--CTE
WITH popvsvac as (
	SELECT 
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingVaccinationTotal
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL and dea.location = 'Canada'
)

SELECT *, (RollingVaccinationTotal/population)*100
FROM popvsvac;


--Temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated 
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated

	SELECT 
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL and dea.location = 'Canada'
	
SELECT *, (RollingPeopleVaccinated/population)*100 as pct
FROM #PercentPopulationVaccinated;


--Creating View to store data for later viualizations
CREATE VIEW PercentPopulationVaccinated as
	SELECT 
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL and dea.location = 'Canada'


--Select the View
SELECT *
FROM PercentPopulationVaccinated
