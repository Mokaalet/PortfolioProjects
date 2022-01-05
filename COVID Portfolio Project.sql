
SELECT	*
FROM	[Portfolio Project]..CovidDeaths
ORDER BY	3,4

SELECT	*
FROM	[Portfolio Project]..CovidDeaths
WHERE Continent is NOT NULL
ORDER BY	3,4


--SELECT	*
--FROM	[Portfolio Project]..CovidVaccinations
--ORDER BY	3,4

--Select the Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths,population
FROM	[Portfolio Project]..CovidDeaths
ORDER BY	1,2

-- Looking at the Total Cases Vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (Total_Deaths/total_cases)*100 AS DeathPercentage
FROM	[Portfolio Project]..CovidDeaths
WHERE Location like '%states%'
ORDER BY	1,2

-- Looking at the Total Cases Vs Population
-- Shows what percentage of population contaracted Covid

SELECT Location, date,  population, total_cases, (Total_cases/population)*100 AS PercentofPopulationInfected
FROM	[Portfolio Project]..CovidDeaths
WHERE Location like '%states%'
ORDER BY	1,2

-- Looking at countries with highest Infection rate compared to Population

SELECT Location, Population, MAX (total_cases) AS HighestInfectionCount, MAX((Total_cases/population))*100 AS PercentofPopulationInfected
FROM	[Portfolio Project]..CovidDeaths
--WHERE Location like '%states%'
GROUP BY	Location, Population
ORDER BY	PercentofPopulationInfected desc

-- Showing the Countries with the Highest Death Count per Population

SELECT Location, MAX(Cast(total_deaths AS INT)) AS TotalDeathCount
FROM	[Portfolio Project]..CovidDeaths
--WHERE Location like '%states%'
WHERE Continent is NOT NULL
GROUP BY	Location
ORDER BY	TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per populatin

SELECT Continent, MAX(Cast(total_deaths AS INT)) AS TotalDeathCount
FROM	[Portfolio Project]..CovidDeaths
--WHERE Location like '%states%'
WHERE Continent is NOT NULL
GROUP BY	Continent
ORDER BY	TotalDeathCount desc


--GLOBAL NUMBERS

--Per Day
SELECT  date, SUM(new_cases) AS Total_Cases, SUM (CAST(New_deaths AS INT))AS Total_Deaths, SUM(CAST(New_Deaths AS INT))/SUM(New_cases)*100 AS DeathPercentage
FROM	[Portfolio Project]..CovidDeaths
--WHERE Location like '%states%'
WHERE Continent is NOT NULL
GROUP BY Date
ORDER BY	1,2

--Across the World death percentage of 1.8%

SELECT  SUM(new_cases) AS Total_Cases, SUM (CAST(New_deaths AS INT))AS Total_Deaths, SUM(CAST(New_Deaths AS INT))/SUM(New_cases)*100 AS DeathPercentage
FROM	[Portfolio Project]..CovidDeaths
--WHERE Location like '%states%'
WHERE Continent is NOT NULL
--GROUP BY Date
ORDER BY	1,2

-- Looking at Total Population vs Vaccinations

SELECT	*
FROM	[Portfolio Project]..CovidVaccinations

SELECT	*
FROM	[Portfolio Project]..CovidDeaths DEA
JOIN	[Portfolio Project]..CovidVaccinations VAC
	ON	DEA.Location = Vac.Location
	AND	dea.Date = Vac.Date

SELECT	DEA.Continent, DEA.Location, DEA. Date, DEA.Population, Vac.New_Vaccinations
FROM	[Portfolio Project]..CovidDeaths DEA
	JOIN	[Portfolio Project]..CovidVaccinations VAC
	ON	DEA.Location = Vac.Location
		AND	dea.Date = Vac.Date
WHERE	DEA.Continent IS NOT NULL
ORDER BY	2,3

SELECT	DEA.Continent, DEA.Location, DEA.Date, DEA.Population, Vac.New_Vaccinations, 
		SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION by DEA.Location ORDER BY dea.location, 
		dea.Date) AS RollingPoepleVaccinated
FROM	[Portfolio Project]..CovidDeaths DEA
	JOIN	[Portfolio Project]..CovidVaccinations VAC
	ON	DEA.Location = Vac.Location
		AND	dea.Date = Vac.Date
WHERE	DEA.Continent IS NOT NULL
ORDER BY	2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPoepleVaccinated)
AS
(
SELECT	DEA.Continent, DEA.Location, DEA.Date, DEA.Population, Vac.New_Vaccinations, 
		SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION by DEA.Location ORDER BY dea.location, 
		dea.Date) AS RollingPoepleVaccinated
FROM	[Portfolio Project]..CovidDeaths DEA
	JOIN	[Portfolio Project]..CovidVaccinations VAC
	ON	DEA.Location = Vac.Location
		AND	dea.Date = Vac.Date
WHERE	DEA.Continent IS NOT NULL
-- ORDER BY	2,3
)

SELECT	*, (RollingPoepleVaccinated/Population)*100
FROM	PopvsVac


-- TEMP TABLE

DROP TABLE if EXISTS #PercentPopulationVaccinated
CREATE TABLE	#PercentPopulationVaccinated
(
Continent NVARCHAR (255),
Location NVARCHAR (255),
Date DATETIME,
Population NUMERIC,
New_Vaccination NUMERIC,
RollingPoepleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT	DEA.Continent, DEA.Location, DEA.Date, DEA.Population, Vac.New_Vaccinations, 
		SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION by DEA.Location ORDER BY dea.location, 
		dea.Date) AS RollingPoepleVaccinated
FROM	[Portfolio Project]..CovidDeaths DEA
	JOIN	[Portfolio Project]..CovidVaccinations VAC
	ON	DEA.Location = Vac.Location
		AND	dea.Date = Vac.Date
WHERE	DEA.Continent IS NOT NULL
-- ORDER BY	2,3

SELECT	*, (RollingPoepleVaccinated/Population)*100
FROM	#PercentPopulationVaccinated



-- Creating View to Store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT	DEA.Continent, DEA.Location, DEA.Date, DEA.Population, Vac.New_Vaccinations, 
		SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION by DEA.Location ORDER BY dea.location, 
		dea.Date) AS RollingPoepleVaccinated
FROM	[Portfolio Project]..CovidDeaths DEA
	JOIN	[Portfolio Project]..CovidVaccinations VAC
	ON	DEA.Location = Vac.Location
		AND	dea.Date = Vac.Date
WHERE	DEA.Continent IS NOT NULL
-- ORDER BY	2,3

SELECT	*
FROM	PercentPopulationVaccinated