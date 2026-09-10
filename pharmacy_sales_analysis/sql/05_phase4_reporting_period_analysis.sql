/* Project: Pharmacy Sales Analysis 
File: 05_phase4_reporting_period_analysis.sql 

Purpose: Analyze pharmacy performance 
based on the reporting-period classification identified from the business reporting process. 

Reporting Period Types: 1. Individual Day 2. Accumulated Day 
Business Rule: for Accumulated Day - Saturday reporting includes Saturday + Sunday sales. 
			   - Certain public holiday sales are included in the preceding reporting period. 
			
Source table : pharmacy_sales */

select case 
			when bill_dt =(select max(bill_dt) from pharmacy_sales) then 'Individual day' -- for last day in dataset
			when bill_dt+interval '1 day' not in (select bill_dt from pharmacy_sales) then 'Accumulated day'
			else 'Individual day'
			end as "Reporting day type",
		count(*) as count_type
from pharmacy_sales
group by "Reporting day type";

-- creating view 
create view pharmacy_sales_view as
select bill_dt , case 
					when bill_dt =(select max(bill_dt) from pharmacy_sales) then 'Individual day'
					when bill_dt+interval '1 day' not in (select bill_dt from pharmacy_sales) then 'Accumulated day'
					else 'Individual day'
					end as "Reporting day type",
extract(DOW from bill_dt) as day_number, TO_CHAR(bill_dt, 'Day') AS day_name, 
extract(MONTH from bill_dt) as month_number, to_char(bill_dt,'Month') as month_name,
start_bno,end_bno, (end_bno-start_bno+1) as bill_counts, 
tot_sale, round((tot_sale/(end_bno-start_bno+1) ),2) as avg_bill_value
from pharmacy_sales;

select * from pharmacy_sales_view;

--1. Individual day performance 
with individual_days_cte as (
select * from pharmacy_sales_view
where "Reporting day type" ='Individual day'
)
--1.a. Highest and lowest sales
(select 'Highest sales' as Metrics , bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where tot_sale = (select max(tot_sale) from individual_days_cte)) union all 
(select 'Lowest sales', bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where tot_sale = (select min(tot_sale) from individual_days_cte)) union all 
--1.b. Highest and lowest bill counts
(select 'Highest bill count' , bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where bill_counts = (select max(bill_counts) from individual_days_cte)) union all 
(select 'Lowest bill count', bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where bill_counts = (select min(bill_counts) from individual_days_cte)) union all 
--1.c. Highest and lowest average bill value
(select 'Highest average bill value' , bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where avg_bill_value = (select max(avg_bill_value) from individual_days_cte)) union all 
(select 'Lowest average bill value', bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where avg_bill_value = (select min(avg_bill_value) from individual_days_cte));

--2. Accumulated day performance 
with individual_days_cte as (
select * from pharmacy_sales_view
where "Reporting day type" ='Accumulated day'
)
--2.a. Highest and lowest sales
(select 'Highest sales' as Metrics , bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where tot_sale = (select max(tot_sale) from individual_days_cte)) union all 
(select 'Lowest sales', bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where tot_sale = (select min(tot_sale) from individual_days_cte)) union all 
--2.b. Highest and lowest bill counts
(select 'Highest bill count' , bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where bill_counts = (select max(bill_counts) from individual_days_cte)) union all 
(select 'Lowest bill count', bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where bill_counts = (select min(bill_counts) from individual_days_cte)) union all 
--2.c. Highest and lowest average bill value
(select 'Highest average bill value' , bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where avg_bill_value = (select max(avg_bill_value) from individual_days_cte)) union all 
(select 'Lowest average bill value', bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where avg_bill_value = (select min(avg_bill_value) from individual_days_cte));

--3. Individual vs Accumulated day comaprison

select "Reporting day type", count(*) as reporting_periods, 
sum(bill_counts) as total_bill_counts,
sum(tot_sale) as total_sales,
round(sum(tot_sale)/ sum(bill_counts),2) as avg_bill_value,
round(avg(tot_sale),2) as average_sale_per_reporting_period,
round(avg(bill_counts),2) as average_bill_counts_per_reporting_period
from pharmacy_sales_view
group by "Reporting day type";

--4. Correlation analysis
--a. relationship between bill count and total sales
--b. average bill value and total sales

select "Reporting day type", round(corr(bill_counts, tot_sale)::numeric,3) as bill_count_sales_correlation,
round(corr(avg_bill_value, tot_sale)::numeric,3) as avg_bill_value_sales_correlation
from pharmacy_sales_view
group by "Reporting day type";


