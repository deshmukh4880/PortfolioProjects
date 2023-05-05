 select *
 from portfolioproject..[covid death]
 order by 3,4

 select *
 from portfolioproject..[covid vaccination]

 --- select data that we are using for project 

select location, date, 
        total_cases, 
		new_cases, total_deaths, population
 from PortfolioProject..[covid death]
 order by 1,2


 --- Tootal cases vs Total Deaths

select location, date, total_cases,total_deaths
  from PortfolioProject..[covid death]
	 where location like '%states%'
	 and continent is not null
        order by 1,2


--- looking at total cases vs population
--- shows what percentage of population got covid

select location, date,
       total_cases,population, 
	    (total_cases/population) * 100 as DeathPercentage
  from PortfolioProject..[covid death]
    order by 1,2

--- looking for countries with highest infection rate compared to population

select location, population, 
       max(total_cases) as HighestInfectionCount,
       max((total_cases/population)) * 100 as PercentagePopulationInfected
  from PortfolioProject..[covid death]
    group by location,population
      order by  PercentagePopulationInfected desc


--- countries with highest death count per population 

select continent,  
       max(cast(total_deaths as int))TotalDeathCount  
  from PortfolioProject..[covid death]
  where continent is not null
    group by continent
      order by  TotalDeathCount  desc


--- global numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
             sum(cast(new_deaths as int))/sum(new_cases ) *100 as DeathPercentage
   from PortfolioProject..[covid death]
	 --group by date
        order by 1,2  

--- Looking at total population vs vaccination 


select  dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
         sum(convert(bigint,vac.new_vaccinations)) 
		 OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--- (RollingPeopleVaccinated/population) *100
			  from PortfolioProject..[covid death] dea
				 join PortfolioProject..[covid vaccination] vac
				   on dea.location = vac.location
					and dea.date = vac.date
					 where dea.continent is not null
						 order by 2,3 


---- USE CTE 

with PopvsVac (continent,location,date,population,new_vaccinations, RollingPeopleVaccinated)
as 
(
select  dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
         sum(convert(bigint,vac.new_vaccinations)) 
		 OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--- (RollingPeopleVaccinated/population) *100
			  from PortfolioProject..[covid death] dea
				 join PortfolioProject..[covid vaccination] vac
				   on dea.location = vac.location
					and dea.date = vac.date
					 where dea.continent is not null
						-- order by 2,3 
						 )
			  select * ,(RollingPeopleVaccinated/population) * 100
			    from PopvsVac


 --- TEMP TABLE ##

 drop table if exists #PercentPopulationVaccinated 
 create table #PercentPopulationVaccinated
 (
 continent nvarchar (255),
 location nvarchar(255),
 date datetime,
 population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 Insert into #PercentPopulationVaccinated
    select  dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
         sum(convert(bigint,vac.new_vaccinations)) 
		 OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--- (RollingPeopleVaccinated/population) *100
			  from PortfolioProject..[covid death] dea
				 join PortfolioProject..[covid vaccination] vac
				   on dea.location = vac.location
					and dea.date = vac.date
					-- where dea.continent is not null
						-- order by 2,3 

 select * ,(RollingPeopleVaccinated/population) * 100
			    from  #PercentPopulationVaccinated


---- Creating view to store data for later visualizations 

create view #PercentagePopulationVaccinated as 
select  dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
         sum(convert(bigint,vac.new_vaccinations)) 
		 OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--- (RollingPeopleVaccinated/population) *100
			  from PortfolioProject..[covid death] dea
				 join PortfolioProject..[covid vaccination] vac
				   on dea.location = vac.location
					and dea.date = vac.date
					where dea.continent is not null
						--order by 2,3 



select *
from PercentagePopulationVaccinated