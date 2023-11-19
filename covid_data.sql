-- changing data type of total_deaths from nvarchar to float 
ALTER TABLE dbo.covid_data_deaths
ALTER COLUMN total_deaths float;




Select * 
From PortfolioProject..covid_data_deaths
order by 3,5

-- Select data for what im going to be using 
 Select Location, date, total_cases, total_deaths, population
 From PortfolioProject..covid_data_deaths
 Order by 1,2



 -- Looking at total cases vs total Deaths 
 -- shows chances of you dying if you get  covid in your country 
 Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_precentage
 From PortfolioProject..covid_data_deaths
 Where location like 'Pakistan'
 and continent is not null
 Order by 1,2




 -- total cases vs population
 -- shows what percentage of population got covid 
 Select Location, date, total_cases,population, (total_cases/population)*100 AS  PercentPopulationInfected
 From PortfolioProject..covid_data_deaths
 Where location like 'Pakistan'
  and continent is not null
 Order by 1,2


 -- looking at countries with highest infection rate compared to population
 Select Location,population,MAX(total_cases) AS highestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
 From PortfolioProject..covid_data_deaths
 --Where location like 'Pakistan'
 where continent is not null
 Group by Location, population
 Order by PercentPopulationInfected desc


 -- showing countries with highest death count per population
 -- using where contient is not null after finding some issues with the data

  Select Location,MAX(total_deaths) AS TotalDeathCount 
 From PortfolioProject..covid_data_deaths
 --Where location like 'Pakistan'
 where continent is not null
 Group by Location
 Order by TotalDeathCount  desc

   
-- BREAKING THINGS down based on Continent
-- Continents with highest death count per-population
   Select continent,MAX(total_deaths) AS TotalDeathCount 
 From PortfolioProject..covid_data_deaths
 --Where location like 'Pakistan'
 where continent is not null
 Group by continent
 Order by TotalDeathCount  desc



 -- Global Numbers 
SELECT SUM(new_cases) AS total_cases,SUM(new_deaths) AS total_deaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100
    END AS death_percentage
FROM PortfolioProject..covid_data_deaths
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY date;

-- looking total population that got vaccinated 
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS addingRollingvaccination
From PortfolioProject..covid_data_deaths dea
join PortfolioProject..covid_data_vacanation vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3 


-- use CTE

with PopvsVac ( Continent, Location,date,population,New_vaccinations,addingRollingvaccination)
as
(
	Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS addingRollingvaccination
	From PortfolioProject..covid_data_deaths dea
		join PortfolioProject..covid_data_vacanation vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
--	order by 2,3 
)

Select *,(addingRollingvaccination/population)*100
from PopvsVac




-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
addingRollingvaccination numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS addingRollingvaccination
	From PortfolioProject..covid_data_deaths dea
		join PortfolioProject..covid_data_vacanation vac
		on dea.location = vac.location
		and dea.date = vac.date
--	where dea.continent is not null
--	order by 2,3 
Select *,(addingRollingvaccination/population)*100
from #PercentPopulationVaccinated




-- Creating view to store data for later visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS addingRollingvaccination
	From PortfolioProject..covid_data_deaths dea
		join PortfolioProject..covid_data_vacanation vac
		on dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null
--	order by 2,3 



	


	
-- Tablau code under sheets 





-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc
