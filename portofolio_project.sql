--select * from CovidVaccination
--order by 3,4

--select * from CovidDeaths
--order by 3,4

--select *
--from PortfolioProject..CovidDeaths

--select data that we are going to be using

select location, date, total_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 

--looking at toal cases vs total deaths

select location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2  --error

--You could only get that error message if one or both of the columns used in the division is a NVARCHAR. 
--You may believe both columns to be integer, but you just cannot get that error message if that was true.
--Use TRY_CAST() to convert the data into numerics 
SELECT
      location
    , DATE
    , total_cases
    , total_deaths
    , CASE 
        WHEN try_cast(total_cases AS NUMERIC(10, 2)) > 0
            THEN (try_cast(total_deaths AS NUMERIC(10, 2)) / try_cast(total_cases AS NUMERIC(10, 2))) * 100.0
        ELSE 0
        END AS death
FROM PortfolioProject..CovidDeaths
where location like 'India' and continent is not null
ORDER BY 1,2

--looking at total cases vs population
--shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as percentPopulatioNCount
from PortfolioProject..CovidDeaths 
--where location like 'India'
where continent is not null
order by 1,2  

--Looking at the location with the highest infection rate
select location, population, max(total_cases) HighestInfectonCount, max((total_cases/population))*100 as percentPopulatioNCount
from PortfolioProject..CovidDeaths 
where continent is not null
group by location, population
order by percentPopulatioNCount desc

--Showing countries with Highest Death per Population
select location, max(cast(total_deaths as int)) TotalDeathCounts
from PortfolioProject..CovidDeaths 
where continent is not null
group by location
order by TotalDeathCounts desc

--LET'S BREAK THINGS DOWN BY CONTINENT
select location, max(cast(total_deaths as int)) TotalDeathCounts
from PortfolioProject..CovidDeaths 
where continent is not null
group by location
order by TotalDeathCounts desc

--GLOBAL NUMBERS
select sum(new_cases) total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccination

select top 1000 d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over(partition by d.location)
from PortfolioProject..CovidDeaths d
left join PortfolioProject..CovidVaccination v
	on d.location = v.location
where d.continent is not null
order by 2,3

--CTE

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over(partition by d.location order by d.location,d.date) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccination v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by 2,3
)
select * from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over(partition by d.location order by d.location,d.date) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccination v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 






