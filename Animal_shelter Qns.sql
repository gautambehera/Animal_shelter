-- Sql questions : Animal shelter 

-- 1. Draw the ERD diagram for this schema ? 

/*2. Print vaccination report for all the animals 
        Name,
		Species,
		Breed,
		Primary_Color,
		Vaccination_Time,
		Vaccine,
		First_Name,
		Last_Name,
		Role
*/

select a.Name,
		a.Species,
		a.Breed,
		a.Primary_Color,
		v.Vaccination_Time,
        v.Vaccine,
		p.First_Name,
		p.Last_Name,
		st.Role
        from  animals a left outer join (
        vaccinations v join persons p   on v.Email=p.Email join staff_assignments st on st.email=p.email)
        on a.Name=v.Name and a.species=v.Species
;

 /*3. Show Count of vaccines received for all Animals before this date 2019-10-01-- Include Animals who are not vaccinated (who received 0 vaccines)
        Name,
		Species,
		Breed,
		Primary_Color,
		Count 
*/
with cte as (select a.Name,a.Species,a.Breed,a.Primary_Color,v.Vaccination_Time,v.Vaccine,
case when v.Vaccination_Time is null then date(0) else v.Vaccination_Time end as vacc_time
from animals a left outer join 
 vaccinations v  on a.Name=v.Name and a.species=v.Species)
select name,species,breed,Primary_Color,count(Vaccination_Time)
from cte
where date(vacc_time) < '2019-10-01'
group by 1,2 
order by 5 desc;

/* 4. Count Number of aninamls of same species who were admitted on the previous date
        Name,
		Species,
		Primary_Color,
		Admission_Date,
		number_of_animals_in_that_species_prev_date */
select   Name,
		Species,
		Primary_Color,
		 Admission_Date, 
        count( Admission_Date) over (partition by Species order by Admission_Date rows between unbounded preceding and 1 preceding) as
        number_of_animals_in_that_species_prev_date
        from animals; 
        
-- 5. Year, Month , Montly total and Annual Revenue percent of Adoption few of that month 
 with cte as (select year(adoption_date) as _year,monthname(adoption_date) as _month,sum( Adoption_Fee)  as Totalmonthly_fee
 from adoptions
 group by 1,2
 order by 1,2)
 ,
cte2 as(select *,sum( Totalmonthly_fee) over(partition by _year) as total_year
 
 from cte)
 select cte._year,cte._month, cte.Totalmonthly_fee,100*(cte.Totalmonthly_fee/cte2.total_year ) as AnnualRev_percentage
 from cte join cte2
 on cte._year=cte2._year and cte._month=cte2._month;
 
 -- Bonus (including species)
 with cte as (select year(adoption_date) as year ,monthname(adoption_date) as Month, species,
 sum(Adoption_Fee)  as Montly_total
 from adoptions
 group by 3,1,2
order by 3,1,2 ),
cte2 as ( select species, year(adoption_date) as Year , sum(adoption_fee) as annual_total
from adoptions 
group by 1,2 
order by 1,2)
select cte.species, cte.year,cte.Month,Montly_total,
annual_total,round( 100*(Montly_total/annual_total),2) as Annual_Revenue_percent_monthly 
from cte join cte2
on cte.year=cte2.Year and 
cte.species=cte2.species
;
 
/*6. Write a query that returns all years in which animals were vaccinated, and the total number of vaccinations given that year.
\\ In addition, the following two columns should be included in the results:
1. The average number of vaccinations given in the previous two years.
2. The percent difference between the current year''s number of vaccinations, and the average of the previous two years.
For the first year, return a NULL for both additional columns. */

with cte as (select year(vaccination_time) as year ,count(*) as Total_vaccine
from vaccinations
group by 1),
cte1 as (select year, Total_vaccine, avg(Total_vaccine) over (  order by year range between 2 preceding and 1 preceding) as
 AVG_vcc_count_prev_years
from cte)
select  year, Total_vaccine, AVG_vcc_count_prev_years,
round(100*(Total_vaccine-AVG_vcc_count_prev_years)/Total_vaccine ,2) as Precenatge_diff 
from cte1 
;
