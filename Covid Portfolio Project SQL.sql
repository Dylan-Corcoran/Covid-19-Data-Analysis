/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Test queries to ensure that data has been imported correctly
SELECT * 
FROM PortfolioProject.coviddeaths
ORDER BY 3, 4;

SELECT *
FROM PortfolioProject.covidvaccinations
ORDER BY 3, 4;


-- Select the required data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.coviddeaths
ORDER BY 1, 2;


-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in a specific location

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage
FROM PortfolioProject.coviddeaths
WHERE location = 'Ireland'
ORDER BY 1, 2;


-- Looking at total cases vs population
-- Shows the percentage of the population that have contracted covid

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS infected_percentage
FROM PortfolioProject.coviddeaths
WHERE location = 'Ireland'
ORDER BY 1, 2;


-- Looking at countries with the highest infection rate compared to population

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population)) * 100 AS infected_percentage
FROM PortfolioProject.coviddeaths
GROUP BY location, population
ORDER BY infected_percentage DESC;


-- Showing the countries with the highest death count per population
-- where continent != '' is included as to avoid duplicates as the data is already grouped into various categories
 
SELECT location, MAX(total_deaths) AS total_death_count
FROM PortfolioProject.coviddeaths
WHERE continent != ''
GROUP BY location
ORDER BY total_death_count DESC;


-- Showing the contintents with the highest death count per population
 
SELECT continent, MAX(total_deaths) AS total_death_count
FROM PortfolioProject.coviddeaths
WHERE continent != ''
GROUP BY continent
ORDER BY total_death_count DESC;


-- GLOBAL NUMBERS

-- GROUP BY date

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths , SUM(new_deaths)/SUM(new_cases) * 100 AS death_percentage
FROM PortfolioProject.coviddeaths
WHERE continent != ''
GROUP BY date
ORDER BY 1, 2;


-- Showing total cases, deaths and the mortality rate for the world

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths , SUM(new_deaths)/SUM(new_cases) * 100 AS death_percentage
FROM PortfolioProject.coviddeaths
WHERE continent != '';


-- JOIN Between the covid vax table and the covid deaths table

SELECT * 
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date;


-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY 2, 3;


-- Population vs new vaccinations + increment of new vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS rolling_vac_count
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY 2, 3;


-- USE CTE 
-- Includes the rolling vaccination count and adds a percentage increment count

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_vac_count)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS rolling_vac_count
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent != ''
)

SELECT *, (rolling_vac_count/population)*100 
FROM PopvsVac;


-- TEMP TABLE
-- Accomplishes the same as above, but with a temp table 

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS rolling_vac_count
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent != '';

SELECT *, (rolling_vac_count/population)*100 
FROM PercentPopulationVaccinated;


-- Creating view to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS rolling_vac_count
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent != '';

SELECT * 
FROM percentpopulationvaccinated;
