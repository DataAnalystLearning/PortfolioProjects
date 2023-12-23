
SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3, 4

/* Select Data we will be using */

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

/*  Total Cases vs Total Deaths  */
/*  Percentage of someone dying if contracting Covid in country of origin */

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%United Kingdom%'
ORDER BY 1, 2

/*  Total Cases vs Population  */
/*  Pecentage of Population that caught Covid  */

SELECT location, date, population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

/*  Countries that have the most cases compared to Population  */

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

/*  Countries with Highest death rate per population  */

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

/*  Data by Continent */

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

/*  Global Numbers  */

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
--WHERE location like '%United Kingdom%' 
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

/*  World data - Total Cases & Total Deaths  */

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
--WHERE location like '%United Kingdom%' 
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

/* Vaccinations */
/* Joining two tables */

Select *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

/* Total population that was vaccinated */

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.Location ORDER BY dea.location, dea.date) AS RollingTotal_of_Vaccinations,
--(RollingTotal_of_Vaccinations/population)*100   /* NOTE Partition only worked when in CAPS!!! */
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingTotal_of_Vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingTotal_of_Vaccinations
--, (RollingTotal_of_Vaccinations/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingTotal_of_Vaccinations/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingTotal_of_Vaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingTotal_of_Vaccinations
--, (RollingTotal_of_Vaccinations/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

SELECT *, (RollingTotal_of_Vaccinations/Population)*100
FROM #PercentPopulationVaccinated

/*  Create View to store data for later visualisations */

CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingTotal_of_Vaccinations
--, (RollingTotal_of_Vaccinations/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

SELECT *, (RollingTotal_of_Vaccinations/Population)*100
FROM PercentPopulationVaccinated

