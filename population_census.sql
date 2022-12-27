select * from [portfolio project]..Data1

--count of rows in dataset

select count(*) from [portfolio project]..Data1
select count(*) from [portfolio project]..Data2

--dataset of Andhra and maharashtra
select * from [portfolio project]..Data1 
where state in ('Andhra Pradesh', 'Maharashtra')

--population of india at that time
select sum(Population) As population from [portfolio project]..Data2

--to find average growth of country in percentage
select avg(growth)*100 as growth_per from [portfolio project]..Data1

--to get average growth percentage of states
select state, avg(growth)*100 as growth_per from [portfolio project]..Data1
group by state
order by growth_per desc

--to get top 3 states with high growth rate
select top 3 state, avg(growth)*100 as growth_per from [portfolio project]..Data1
group by state
order by growth_per desc



--to get average sex ratio
select state, round(avg(Sex_Ratio),0) as avg_sexratio from [portfolio project]..Data1 
group by state
order by avg_sexratio desc

--average literacy rate
select state, round(avg(Literacy),0) as avg_literacy_rate from [portfolio project]..Data1 
group by state
order by avg_literacy_rate desc

--to get states with literacy rate of more than 90
select state, round(avg(Literacy),0) as avg_literacy_rate from [portfolio project]..Data1 
group by state
having round(avg(Literacy),0)>90
order by avg_literacy_rate desc

--create top 3 and bottom 3 states with literacy rate

--top 3 states
drop table if exists #top_states;
create table #top_states
(State nvarchar(255),
topstates float)

insert into #top_states
select state, round(avg(Literacy),0) as avg_literacy_rate from [portfolio project]..Data1 
group by state
order by avg_literacy_rate desc

select top 3 * from #top_states order by topstates desc;

--bottom 3 states
drop table if exists #bottom_states;
create table #bottom_states
(State nvarchar(255),
bottomstates float)

insert into #bottom_states
select state, round(avg(Literacy),0) as avg_literacy_rate from [portfolio project]..Data1 
group by state
order by avg_literacy_rate Asc

select top 3 * from #bottom_states order by bottomstates asc;

--showing both top and bottom states using union operator

select * from (select top 3 * from #top_states order by topstates desc) a
union
select * from (select top 3 * from #bottom_states order by bottomstates asc) b


--states starting with letters a, b or c
select distinct State from [portfolio project]..Data1
where lower(State) like 'a%' or lower(State) like 'b%'  or lower(State) like 'c%' 

--joining both tables
select  a.District,a.State, a.Sex_Ratio, b.Population from [portfolio project]..Data1 a inner join [portfolio project]..Data2 b on a.District=b.District

--from the data the population of males and females can be found 
--sex ratio = females/males
--females+males=population
--females=population-males
--population-males = sex ratio*males
--males= population / (sex ratio+1)
--females= population - population/(sex ratio +1)
--females= population*sex ratio/(sex ratio +1)

--total males and females 

select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from [portfolio project]..Data1 a inner join [portfolio project]..Data2 b on a.district=b.district ) c) d
group by d.state;

--total literate people= literacy ratio * population
--total illiterate people= (1-literacy ratio)*population

--total literacy rate
select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)* d.population,0) illiterate_people from
(select a.district,a.state,a.literacy/100 literacy_ratio,b.population from [portfolio project]..Data1 a 
inner join [portfolio project]..Data2 b on a.district=b.district) d) c
group by c.state


--to find population of previous census
--previous population + (growth*previous population)= current population
--previous population(1+growth)=current population
--previous population = current population/(1+growth)

--to find previous population and current population
select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from [portfolio project]..Data1 a inner join [portfolio project]..Data2 b on a.district=b.district) d) e
group by e.state)m

--population vs area

select (g.total_area/g.previous_census_population)  as previous_census_population_vs_area, (g.total_area/g.current_census_population) as 
current_census_population_vs_area from
(select q.*,r.total_area from (

select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from [portfolio project]..Data1 a inner join [portfolio project]..Data2 b on a.district=b.district) d) e
group by e.state)m) n) q inner join (

select '1' as keyy,z.* from (
select sum(area_km2) total_area from [portfolio project]..Data2)z) r on q.keyy=r.keyy) g

--to output top 3 districts from every state

select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from [portfolio project]..Data1) a

where a.rnk in (1,2,3) order by state

