select * from [Portfolio-Project]..CovidDeaths

Select *
From [Portfolio-Project]..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio-Project]..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact covid in your country[India]

Select Location, date, total_cases,total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
From [Portfolio-Project]..CovidDeaths
Where location like 'India'
and continent is not null 
order by 1,2

--Total Cases vs Total population
-- Shows likelihood of dying if you contact covid in your country[India]
Select Location, date, population,total_cases,round( (total_cases/population)*100,2) as DeathPercentage
From [Portfolio-Project]..CovidDeaths
Where location like 'India'
and continent is not null 
order by 1,2  

-- Countries with Highest Infection Rate compared to Population
Select Location, date, max(total_cases) as 'HighestInfectionCount',round( max((total_cases/population))*100,2) as PercentPopulationInfected
From [Portfolio-Project]..CovidDeaths
--Where location like 'India'
group by Location, date
order by  PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
select location,max(cast(total_deaths as int)) as 'TotalDeathCount'
from [Portfolio-Project]..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
Select continent,max(total_deaths) as 'TotalDeathCount'
from [Portfolio-Project]..CovidDeaths
where continent is  not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select date,sum(new_cases) as 'Total_newCases',sum(new_deaths) as 'Total_newDeaths',SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
from [Portfolio-Project]..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(vac.new_vaccinations)over(partition by dea.location order by dea.location,dea.date) as 'RollingPeopleVaccinated'
,--(RollingPeopleVaccinated/dea.population)*100
From [Portfolio-Project]..CovidDeaths dea
Join [Portfolio-Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query 

with PvsV(continent,location,data,population,vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(vac.new_vaccinations)over(partition by dea.location order by dea.location,dea.date) as 'RollingPeopleVaccinated'
From [Portfolio-Project]..CovidDeaths dea
Join [Portfolio-Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location='India'
)
select *,(RollingPeopleVaccinated/population)*100 from PvsV


--temp table
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio-Project]..CovidDeaths dea
Join [Portfolio-Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated