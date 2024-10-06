SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 3,4;

-- SELECT *
-- FROM PortfolioProject.dbo.CovidVaccinations$
-- ORDER BY 3,4;

-- Select Data that we are going to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths$
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid on your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2;

-- Visualizing Total Cases vs Population
-- Percentage population with COVID
SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationAffected
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like '%Kenya%'
ORDER BY 1,2;


-- Countries with Highest infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected desc;


-- Contries with highest death count per Population
SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is null
GROUP BY Location
ORDER BY TotalDeathCount desc;

-- Visualizing continents with the highest  death count per population
SELECT date, continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY continent, date
ORDER BY TotalDeathCount desc;


-- Global Numbers
SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2;

-- Visualizing Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;


-- Use CTE

WITH popvsvac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT *, ( RollingPeopleVaccinated/population)*100
FROM popvsvac


-- TEMP Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, ( RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating Views for Later Visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated