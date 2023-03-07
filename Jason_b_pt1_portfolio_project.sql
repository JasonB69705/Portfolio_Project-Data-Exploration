select * from CovidDeath
where continent is not null
order by 3,4;


--select * from CovidVaccinations
--order by 3,4;

select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeath
where continent is not null
order by 1,2

-- looking at amount of total cases and deaths
-- displays overtime the death rate if you get covid-19 in the country you live in

select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Death_Percentage
from CovidDeath
where location like '%states%'
order by 1,2


-- exploring total cases and population

select Location, date, total_cases, population, (total_cases/population) * 100 as Percent_Population_Contaminated
from CovidDeath
where location like '%states%'
order by 1,2

--locating countries with highest contraction rate compared to population

select Location, MAX(total_cases) as HighestContaminationCount, population, MAX((total_cases/population)) * 100 as Percent_Population_Contaminated
from CovidDeath
--where location like '%states%'
where continent is not null
group by population,location
order by Percent_Population_Contaminated desc



-- Displaying Countries with higest death rate per population



select Location, MAX(cast(Total_deaths as int)) as Total_death_rate
from CovidDeath
--where location like '%states%'
where continent is not null
group by location
order by Total_death_rate desc


-- seperating by continent
select continent, MAX(cast(Total_deaths as int)) as Total_death_rate
from CovidDeath
--where location like '%states%'
where continent is not null
group by continent
order by Total_death_rate desc

-- displaying continent with the highest death rate per population

select continent, MAX(cast(Total_deaths as int)) as Total_death_rate
from CovidDeath
--where location like '%states%'
where continent is not null
group by continent
order by Total_death_rate desc



--exploring global numbers

select date, SUM(new_cases), SUM(cast(new_deaths as int))--, total_deaths, (total_deaths/total_cases) * 100 as Death_Percentage
from CovidDeath
--where location like '%states%'
where continent is not null
group by date
order by 1,2


--exploring global numbers pt2

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as Death_Percentage
from CovidDeath
--where location like '%states%'
where continent is not null
order by 1,2


-- seeing total vaccination vs total population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Number_of_people_vaccinated
--, (Number_of_people_vaccinated/population) *100
from CovidDeath dea
join CovidVaccinations vac 
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using a common table expression to receive calcuations on partiton in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea 
join CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- using a temporary table
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
From CovidDeath dea 
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--creating a view for future visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 