Use [Practicedb]
GO

SELECT TOP 3 * FROM [dbo].[CovidDeathsData]
ORDER BY 3, 4

SELECT TOP 3 * FROM [dbo].[CovidVaccinationsData] 
ORDER BY 3, 4


-- global numbers

SELECT continent, location, date, population, total_cases, total_deaths FROM [dbo].[CovidDeathsData]
where continent IS NOT NULL
ORDER BY 1, 2


--Looking at global total_cases vs total_deaths (continent/country wise)

SELECT continent, location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS PercentageDeaths
FROM [dbo].[CovidDeathsData]
where continent IS NOT NULL
ORDER BY 2, 3


--Looking at India total_cases vs total_deaths

SELECT continent, location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS PercentageDeaths
FROM [dbo].[CovidDeathsData]
Where continent IS NOT NULL AND location like 'India'
ORDER BY 2, 3


--Looking at global population vs total_cases (continent/country wise)

SELECT continent, location, date, population, total_cases, (total_cases/population)*100 AS percentage_infections 
FROM [dbo].[CovidDeathsData]
where continent IS NOT NULL
ORDER BY 2, 3


--Looking at India population vs total_cases

SELECT continent, location, date, population, total_cases, (total_cases/population)*100 AS percentage_infections 
FROM [dbo].[CovidDeathsData]
where continent IS NOT NULL AND location LIKE 'India'
ORDER BY 2, 3


--Looking at countries with highest infection rates

SELECT continent, location, MAX(population) AS total_population, MAX(total_cases) AS total_cases, (MAX(total_cases)/MAX(population))*100 AS max_infections_rate 
FROM [dbo].[CovidDeathsData]
where continent IS NOT NULL
GROUP BY location, continent
ORDER BY 2


--Showing countries with highest death count per population

SELECT location, MAX(population) AS total_population, MAX(CAST(total_deaths AS int)) AS total_deaths, (MAX(total_deaths)/MAX(population))*100 AS max_deaths_rate
From [dbo].[CovidDeathsData]
where continent IS NOT NULL
GROUP BY location
ORDER BY max_deaths_rate DESC


--Showing continent with highest death count per population

SELECT continent, MAX(population) AS total_population, MAX(CONVERT(int, total_deaths)) AS total_deaths, (MAX(total_deaths)/MAX(population))*100 AS max_deaths_rate
From [dbo].[CovidDeathsData]
where continent IS NOT NULL
GROUP BY continent
ORDER BY max_deaths_rate DESC


--Gobal death percentage

SELECT location, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS gobal_death_rate
From [dbo].[CovidDeathsData]
where continent IS NOT NULL
GROUP BY location
ORDER BY 1


-- Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [dbo].[CovidDeathsData] dea
JOIN [dbo].[CovidVaccinationsData] vac
ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent IS NOT NULL
ORDER BY 2


-- Total population vs vaccinations with Rolling Vaccination count

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) Over (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationRollingCount
FROM [dbo].[CovidDeathsData] dea
JOIN [dbo].[CovidVaccinationsData] vac
ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent IS NOT NULL
ORDER BY 2, 3


-- Percentage of population vaccinated 
--CTE

WITH popvsvacc (continent, location, date, population, new_vaccinations,VaccinationRollingCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) Over (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationRollingCount
FROM [dbo].[CovidDeathsData] dea
JOIN [dbo].[CovidVaccinationsData] vac
ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent IS NOT NULL
)

SELECT continent, location, date, population, new_vaccinations,VaccinationRollingCount, 
(VaccinationRollingCount/population)*100 AS PercentageVaccinated
FROM popvsvacc
ORDER BY 2, 3


-- Percentage of population vaccinated                           
--Using Temp Table

DROP TABLE IF EXISTS #PercentagePopulationVaccinated

CREATE TABLE #PercentagePopulationVaccinated
(
continent NVARCHAR(255) NULL, 
location NVARCHAR(255) NULL, 
date DATE, 
population int, 
new_vaccinations BIGINT,
VaccinationRollingCount BIGINT
)

INSERT INTO #PercentagePopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(ISNULL(CAST(vac.new_vaccinations AS BIGINT), 0)) Over (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationRollingCount
FROM [dbo].[CovidDeathsData] dea
JOIN [dbo].[CovidVaccinationsData] vac
ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent IS NOT NULL


SELECT continent, location, date, population, new_vaccinations,VaccinationRollingCount, 
(VaccinationRollingCount/population)*100 AS PercentageVaccinated
FROM #PercentagePopulationVaccinated
ORDER BY 2, 3


-- Percentage of population vaccinated
--Using Views


CREATE VIEW vWPercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(ISNULL(CAST(vac.new_vaccinations AS BIGINT), 0)) Over (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationRollingCount
FROM [dbo].[CovidDeathsData] dea
JOIN [dbo].[CovidVaccinationsData] vac
ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent IS NOT NULL

SELECT continent, location, date, population, new_vaccinations,VaccinationRollingCount, 
(VaccinationRollingCount/population)*100 AS PercentageVaccinated
FROM vWPercentPopulationVaccinated
ORDER BY 2, 3