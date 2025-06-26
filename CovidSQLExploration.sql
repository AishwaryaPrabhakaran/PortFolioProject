SELECT * 
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Total Cases vs Total Deaths
SELECT location,date,new_cases,total_cases,total_deaths,population 
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'India'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PopulationInfectedPercent 
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by location,population
order by PopulationInfectedPercent desc

-- Countries with Highest Death Count per Population
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- Showing contintents with the highest death count per population
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
select sum(new_cases) as TotalNewCases,sum(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location = 'India'
and continent is not null 
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Use CTE
With PopVsVac AS(
	Select 
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations, 
		SUM(CONVERT(INT,vac.new_vaccinations))
			OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
	From 
		PortfolioProject..CovidDeaths dea
	Join 
		PortfolioProject..CovidVaccinations vac
	On 
		dea.location = vac.location AND dea.date = vac.date
	where 
		dea.continent is not null
)
SELECT 
	*, 
	(CAST(RollingPeopleVaccinated as FLOAT)/Population) * 100 as PercentVaccinated
FROM
	PopVsVac



--Use TempTable
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATE,
    Population NUMERIC(18,2),
    New_vaccinations NUMERIC(18,2),
    RollingPeopleVaccinated NUMERIC(18,2)
);
-- Insert data with rolling calculation
INSERT INTO PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    TRY_CAST(vac.new_vaccinations AS NUMERIC(18,2)),
    SUM(TRY_CAST(vac.new_vaccinations AS NUMERIC(18,2))) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
	From 
		PortfolioProject..CovidDeaths dea
	Join 
		PortfolioProject..CovidVaccinations vac
	On 
		dea.location = vac.location AND dea.date = vac.date
	where 
		dea.continent is not null
-- Final output with percentage calculation
SELECT 
    *, 
	CASE When Population > 0 Then (RollingPeopleVaccinated/Population)* 100
		ELSE NULL
    END AS PercentVaccinated
FROM
	PercentPopulationVaccinated

--CREATE VIEW
-- DO NOT put anything above this line in the same batch
CREATE VIEW VaccinatedPopulationView AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    TRY_CAST(vac.new_vaccinations AS NUMERIC(18,2)) AS New_vaccinations,
    SUM(TRY_CAST(vac.new_vaccinations AS NUMERIC(18,2))) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated,
    CASE 
        WHEN dea.population > 0 THEN 
            SUM(TRY_CAST(vac.new_vaccinations AS NUMERIC(18,2))) 
                OVER (PARTITION BY dea.location ORDER BY dea.date) * 100.0 / dea.population
        ELSE NULL
    END AS PercentVaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;



