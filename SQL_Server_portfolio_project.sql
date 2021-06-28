-- checking covid_deaths table
select * from covid_deaths where continent is not null
-- checking covid_vaccinations table
select * from covid_vaccinations
-- selecting the required data
select location, date, population, total_cases, new_cases, total_deaths
from covid_deaths
where continent is not null
order by 1, 2

-- Checking total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 
as death_percentage
from covid_deaths
where continent is not null
order by 1, 2

-- Checking death percentage for India
select location, date, total_cases, total_deaths, 
round((total_deaths/total_cases) * 100, 2) as death_percentage 
from covid_deaths
where location = 'India'
order by 1, 2

-- Checking total cases vs population
select location, date, total_cases, population, 
round((total_cases/population) * 100, 2) as case_percentage 
from covid_deaths
where location = 'India'
order by 1, 2

-- Checking max total cases and max no. of cases per population for each country
select location, max(total_cases) as max_cases, population, 
max(round((total_cases/population) * 100, 2)) as spread_percentage 
from covid_deaths
where continent is not null
group by location, population
order by spread_percentage desc

-- Checking highest no. of deaths for each country
select location, max(cast(total_deaths as int)) as MaxDeathCount
from covid_deaths
where continent is not null
group by location
order by MaxDeathCount desc

-- Global numbers
select date, sum(new_cases) cases, sum(cast(new_deaths as int)) deaths,
(sum(cast(new_deaths as int))/sum(new_cases)) * 100 DeathPercentage
from covid_deaths
where continent is not null
group by date
order by 1, 2

-- Checking total deaths, cases and death percentage till now
select sum(new_cases) cases, sum(cast(new_deaths as int)) deaths,
round((sum(cast(new_deaths as int))/sum(new_cases)) * 100, 2) DeathPercentage
from covid_deaths
where continent is not null

-- Checking total_tests for each country
select location, sum(cast(total_tests as bigint)) agg_tests
from covid_vaccinations
where continent is not null
group by location
order by 2 desc

-- Checking avg tests per thousand and avg positive rate for each country
select location, round(avg(cast(new_tests_per_thousand as float)), 2) avg_tests, 
round(avg(cast(positive_rate as float)), 2) avg_positivity
from covid_vaccinations
where continent is not null
group by location
order by 1 

-- total vaccines administered by each country
select location, sum(cast(new_vaccinations as bigint)) total_vax
from covid_vaccinations
where continent is not null
group by location
order by 2 desc

-- Checking total population vs vaccine
-- Using CTE

with covax 
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by
cd.location, cd.date) RollingPopulationVax
from covid_deaths cd
join covid_vaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null)
select continent, location, population, 
max(round((RollingPopulationVax/population) * 100, 2)) populationvaxinated_per_100 
from covax
group by continent, location, population
order by 4 desc

-- create table covax
drop table if exists covax
create table covax
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPopulationVax numeric
)
insert into covax
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by
cd.location, cd.date) RollingPopulationVax
from covid_deaths cd
join covid_vaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null

select *, round((RollingPopulationVax/population) * 100, 2)
from covax

-- creating view for later visualizations
go

create view
populationvaccinated as 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by
cd.location, cd.date) RollingPopulationVax
from covid_deaths cd
join covid_vaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null

select * from populationvaccinated

