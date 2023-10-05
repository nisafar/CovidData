Select *
from CovidDeaths
order by 3,4

--Select *
--from CovidVaccinations
--order by 3,4

--Select data we're gonna be use

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--Looking at total cases vs total deaths

-- Shows death percantage
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
Where location like 'Indo%'
order by 1,2

-- shows what percentage of population got covid
Select location, date, total_cases,population, (total_cases/population)*100 as InfectedPercentage
from CovidDeaths
Where location like 'Indo%'
order by 1,2

-- Looking at country with highest infection rate compared to population
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death per Population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- let's break things by continent

-- Showing continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by Continent
order by TotalDeathCount desc


-- global numbers

Select date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths
, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

Select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths
, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2


-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) 
AS 
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
        , SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
    FROM CovidDeaths dea
    JOIN CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM pop_vs_vac
--ORDER BY location, date



-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
location nvarchar (255),
dat datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
        , SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated





-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS


Create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
        , SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


select *
from PercentPopulationVaccinated

