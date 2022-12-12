Select *
From [hello world]..['owid-covid-data (2)$']
where continent is not null
order by 3,4




--Select *
--From [hello world]..['owid-covid-data (2)$'ExternalData_1]
--order by 3,4

---SELECT DATA that we are going to be using

Select Location,date, total_cases, new_cases, total_deaths, population
From [hello world]..['owid-covid-data (2)$'ExternalData_1]
where continent is not null
order by 1, 2
---Looking at Total Cases vs Total Deaths 
---Shows likelihood of dying if you contract covid in your country

Select Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [hello world]..['owid-covid-data (2)$'ExternalData_1]
Where location like '%states%'
where continent is not null
order by 1, 2



-- looking at total cases vs population
---shows what percentage of population got covid 
select Location, date, total_cases, Population , (total_cases/population)*100 as DeathPercentage
From [hello world]..['owid-covid-data (2)$'ExternalData_1]
--Where location like '%states%'
order by 1, 2






--looking at countries with higest infection   rate compared to population 
select Location,  Max(total_cases) as HigestInfectionCount, Population , Max((total_cases/population))*100 as PercentPopulationInfected 
From [hello world]..['owid-covid-data (2)$'ExternalData_1]

--Where location like '%states%'
Group by Population,Location
where continent is not null
order by PercentPopulationInfected desc


---Showing Countries with Higest Death Count per population 
select Location,  Max(total_cases) as HigestInfectionCount, Population , Max((total_cases/population))*100 as PercentPopulationInfected 
From [hello world]..['owid-covid-data (2)$'ExternalData_1]
--Where location like '%states%'
Group by Population,Location
where continent is not null
order by PercentPopulationInfected desc


Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From [hello world]..['owid-covid-data (2)$'ExternalData_1]
where continent is not null
Group by Location 

order by TotalDeathCount desc

--Lets break things by continent 


Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From [hello world]..['owid-covid-data (2)$'ExternalData_1]
where continent is  null
Group by continent
order by TotalDeathCount desc

--showing continent with the higest death count per population
Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From [hello world]..['owid-covid-data (2)$'ExternalData_1]
where continent is  null
Group by continent
order by TotalDeathCount desc





--GLOBAL NUMBERS 
Select Location,date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death ,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [hello world]..['owid-covid-data (2)$'ExternalData_1]
--Where location like '%states%'
order by 1, 2



--looking at total population vs vaccinations 


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(CONVERT(float,vac.new_vaccinations )) over (partition by dea.Location order by dea.location, dea.date) as
RollingPeopleVaccinated
--, (RollingPeopleVaccnated/population)*100

From [hello world]..['owid-covid-data (2)$'ExternalData_1] dea
Join [hello world]..['owid-covid-data (2)$']  vac
     On dea.location =vac.location 
	 and dea.date= vac.date
where dea.continent is not null
order by  2 ,3 

--use cte

with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(CONVERT(float,vac.new_vaccinations )) over (partition by dea.Location Order by dea.location, dea.date) as
RollingPeopleVaccinated
, (RollingPeopleVaccnated/population)*100

From [hello world]..['owid-covid-data (2)$'ExternalData_1] dea
Join [hello world]..['owid-covid-data (2)$']  vac
     On dea.location =vac.location 
	 and dea.date= vac.date
where dea.continent is not null
order by  2 ,3 
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac




---TMP TABLE
Drop Table if exists #PercentPopulationVaccinated

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
,Sum(CONVERT(float,vac.new_vaccinations )) over (partition by dea.Location Order by dea.location, dea.date) as
RollingPeopleVaccinated
--, (RollingPeopleVaccnated/population)*100

From [hello world]..['owid-covid-data (2)$'ExternalData_1] dea
Join [hello world]..['owid-covid-data (2)$']  vac
     On dea.location =vac.location 
	 and dea.date= vac.date
where dea.continent is not null
order by  2 ,3 
select *, (RollingPeopleVaccinated/population)*100


--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(CONVERT(float,vac.new_vaccinations )) over (partition by dea.Location Order by dea.location, dea.date) as
RollingPeopleVaccinated
--, (RollingPeopleVaccnated/population)*100

From [hello world]..['owid-covid-data (2)$'ExternalData_1] dea
Join [hello world]..['owid-covid-data (2)$']  vac
     On dea.location =vac.location 
	 and dea.date= vac.date
where dea.continent is not null
--order by  2 ,3 


select *
from PercentPopulationVaccinated
