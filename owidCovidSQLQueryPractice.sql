Select *
From PortfolioProjectSQL..owidCovid
where continent is not null
order by 3,4

-- Selec data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectSQL..owidCovid
where continent is not null
order by 1,2

-- What is the liklehood of expiring due to contraction of covid in given country?
-- In this case United States
-- Total Cases versus Total Population

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentExpired 
From PortfolioProjectSQL..owidCovid
where location like 'United States'
and continent is not null
order by 1,2

-- What is the liklehood of expiring due to contraction of covid in given country?
-- In this case Sri Lanka
-- Total Cases versus Total Population

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentExpired 
From PortfolioProjectSQL..owidCovid
where location like 'Sri Lanka'
and continent is not null
order by 1,2

-- What % of a given population has already been infected with covid?
-- In this case United States (daily breakdown)
-- Total cases versus population
Select location, date, Population, total_cases, (total_cases/population)*100 as RatePopulationInfected
From PortfolioProjectSQL..owidCovid
where location like '%states%'
and continent is not null
order by 1,2

-- What countries have the highest rates of infection as % of population?
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjectSQL..owidCovid
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- What countries have seen the most total deaths due to covid?
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjectSQL..owidCovid
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- What countries have seen the most total deaths as % of population?
Select Location, population, MAX(cast(Total_deaths as int)) as TotalDeathCount, (MAX(cast(Total_deaths as int))/population*100) as PercentPopulationExpired
From PortfolioProjectSQL..owidCovid
Where continent is not null 
Group by Location, population
order by PercentPopulationExpired desc

-- Which continents have seen the mosts deaths?
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjectSQL..owidCovid
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Global numbers --

-- Total cases, total deaths and % population expired due to covid complications
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjectSQL..owidCovid
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProjectSQL..CovidDeaths dea
Join PortfolioProjectSQL..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectSQL..CovidDeaths dea
Join PortfolioProjectSQL..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
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
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectSQL..CovidDeaths dea
Join PortfolioProjectSQL..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectSQL..CovidDeaths dea
Join PortfolioProjectSQL..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 