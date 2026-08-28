--Phase 1. Overall performance
with overall_performance_cte as(
select bill_dt as reporting_dt,
start_bno, end_bno, (end_bno-start_bno+1) as bill_counts,
tot_sale, exempt, (amt_5+amt_18+amt_28) taxable_sales,tot_gst
from pharmacy_sales)

select 
sum(bill_counts) as total_bills,
sum(tot_sale) as total_sales,
sum(exempt) as total_exempt_sales,
sum(taxable_sales) as total_taxable_sales,
sum(tot_gst) as total_gst,
round(sum(tot_sale)/sum(bill_counts),2) as avg_bill_value
from overall_performance_cte;



-- Phase 2. GST analysis

with GST_analysis_cte as (
(select '5%' as GST_rate, sum(amt_5) as Taxable_sales, sum(gst_5) as GST_collected
from pharmacy_sales)
union all
(select '18%', sum(amt_18), sum(gst_18) 
from pharmacy_sales)
union all
(select '28%', sum(amt_28), sum(gst_28) 
from pharmacy_sales))

select GST_rate, Taxable_sales, round(Taxable_sales/sum(Taxable_sales) over() *100,2) as Sales_contribution_pct,
GST_collected, round(GST_collected/sum(GST_collected) over() *100,2) as GST_contribution_pct
from GST_analysis_cte;

with total_sales_cte as(
(select 'Exempt' as Sales_category, sum(exempt) as Total_sales from pharmacy_sales)
union all
(select 'GST_5%', sum(amt_5) from pharmacy_sales)
union all
(select 'GST_18%' , sum(amt_18) from pharmacy_sales)
union all
(select 'GST_28%' , sum(amt_28) from pharmacy_sales))
select Sales_category, Total_sales, round(Total_sales/sum(Total_sales) over()*100,2) as Sales_contribution_percent
from total_sales_cte;

--Phase 3. Monthly reporting period analysis

with monthly_analysis_cte as (
select extract(Month from bill_dt) as month_number, to_char(bill_dt,'Month') as month_name,
sum(tot_sale) as total_sales, sum(end_bno-start_bno+1):: numeric as total_bills,
sum(tot_gst) as total_gst, sum(exempt) as total_exempt,
sum(amt_5+amt_12+amt_18+amt_28) as taxable_sales,
round(sum(tot_sale)/sum(end_bno-start_bno+1),2) as avg_bill_value
from pharmacy_sales
group by extract(Month from bill_dt), to_char(bill_dt,'Month')),

previous_month_analysis as(
select month_number, month_name,
total_sales, lag(total_sales) over(order by month_number) as previous_month_total_sales,
total_bills, lag(total_bills) over(order by month_number) as previous_month_bills,
total_gst, lag(total_gst) over(order by month_number) as previous_month_total_gst,
avg_bill_value, lag(avg_bill_value) over(order by month_number) as previous_avg_bill_value
from monthly_analysis_cte)

select month_number,month_name,
total_sales, round((total_sales - previous_month_total_sales)/previous_month_total_sales*100,2) as sales_growth_pct,
total_bills, round((total_bills-previous_month_bills)/previous_month_bills*100,2) as bill_growth_pct,
total_gst, round((total_gst-previous_month_total_gst)/previous_month_total_gst*100,2) as gst_growth_pct,
avg_bill_value, round((avg_bill_value- previous_avg_bill_value)/previous_avg_bill_value*100,2) as avg_bill_value_growth_pct
from previous_month_analysis;

--Phase 4. Reporting period Performance analysis

select * from pharmacy_sales_view;

-- categorizing data into individual and accumulated day.

select  case 
			when bill_dt =(select max(bill_dt) from pharmacy_sales) then 'Individual day'
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

--- analysing highest and lowest for all reporting days 
--Highest and lowest sales
(select 'Highest sales' as Metrics, bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from pharmacy_sales_view
where tot_sale = (select max(tot_sale) from pharmacy_sales_view)) union all 
(select 'Lowest sales', bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from pharmacy_sales_view
where tot_sale = (select min(tot_sale) from pharmacy_sales_view)) union all 
--Highest and lowest bill counts
(select 'Highest bill count' as Metrics, bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from pharmacy_sales_view
where bill_counts = (select max(bill_counts) from pharmacy_sales_view)) union all 
(select 'Lowest bill count', bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
 from pharmacy_sales_view
where bill_counts = (select min(bill_counts) from pharmacy_sales_view))union all 
--Highest and lowest average bill value
(select 'Highest average bill value' as Metrics, bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from pharmacy_sales_view
where avg_bill_value = (select max(avg_bill_value) from pharmacy_sales_view))union all 
(select 'Lowest average bill value', bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from pharmacy_sales_view
where avg_bill_value = (select min(avg_bill_value) from pharmacy_sales_view));

--- analysing highest and lowest for all individual days 

with individual_days_cte as (
select * from pharmacy_sales_view
where "Reporting day type" ='Individual day'
)
(select 'Highest sales' as Metrics , bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where tot_sale = (select max(tot_sale) from individual_days_cte)) union all 
(select 'Lowest sales', bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where tot_sale = (select min(tot_sale) from individual_days_cte)) union all 
--Highest and lowest bill counts
(select 'Highest bill count' , bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where bill_counts = (select max(bill_counts) from individual_days_cte)) union all 
(select 'Lowest bill count', bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where bill_counts = (select min(bill_counts) from individual_days_cte)) union all 
--Highest and lowest average bill value
(select 'Highest average bill value' , bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where avg_bill_value = (select max(avg_bill_value) from individual_days_cte)) union all 
(select 'Lowest average bill value', bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where avg_bill_value = (select min(avg_bill_value) from individual_days_cte));

--- analysing highest and lowest for all accumulted days 

with individual_days_cte as (
select * from pharmacy_sales_view
where "Reporting day type" ='Accumulated day'
)
(select 'Highest sales' as Metrics , bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where tot_sale = (select max(tot_sale) from individual_days_cte)) union all 
(select 'Lowest sales', bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where tot_sale = (select min(tot_sale) from individual_days_cte)) union all 
--Highest and lowest bill counts
(select 'Highest bill count' , bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where bill_counts = (select max(bill_counts) from individual_days_cte)) union all 
(select 'Lowest bill count', bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where bill_counts = (select min(bill_counts) from individual_days_cte)) union all 
--Highest and lowest average bill value
(select 'Highest average bill value' , bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where avg_bill_value = (select max(avg_bill_value) from individual_days_cte)) union all 
(select 'Lowest average bill value', bill_dt, day_name, month_name, bill_counts, tot_sale, avg_bill_value
from individual_days_cte
where avg_bill_value = (select min(avg_bill_value) from individual_days_cte));

--Phase 5 - Day of week & reporting pattern analysis

select * from pharmacy_sales_view;

-- all reporting days
select day_number, trim(day_name), count(*) as reporting_periods, sum(tot_sale) as total_sale,
sum(bill_counts) as total_bill_counts, round(sum(tot_sale)/sum(bill_counts),2) as avg_bill_value,
round(avg(tot_sale),2) as avg_sales_per_period
from pharmacy_Sales_view
group by day_number,trim(day_name)
order by day_number;

-- Individual days only
select day_number, trim(day_name) as day_name, count(*) as reporting_periods, sum(tot_sale) as total_sale,
sum(bill_counts) as total_bill_counts, round(sum(tot_sale)/sum(bill_counts),2) as avg_bill_value,
round(avg(tot_sale),2) as avg_sales_per_period
from pharmacy_Sales_view
where "Reporting day type" = 'Individual day'
group by day_number,trim(day_name)
order by avg_sales_per_period desc;

--Accumulated days only
select day_number, trim(day_name) as day_name, count(*) as reporting_periods, sum(tot_sale) as total_sale,
sum(bill_counts) as total_bill_counts, round(sum(tot_sale)/sum(bill_counts),2) as avg_bill_value,
round(avg(tot_sale),2) as avg_sales_per_period
from pharmacy_Sales_view
where "Reporting day type" = 'Accumulated day'
group by day_number,trim(day_name)
order by day_number;

--Phase 6. GST and sales contribution analysis

with gst_analysis_cte as(
(select 'Exempt' as gst_slab, sum(exempt) as taxable_sales, 0.00 as gst_collected
from pharmacy_sales)
union all
(select '5%', sum(amt_5), sum(gst_5)
from pharmacy_sales)
union all
(select '12%', sum(amt_12), sum(gst_12)
from pharmacy_sales)
union all
(select '18%', sum(amt_18), sum(gst_18)
from pharmacy_sales)
union all
(select '28%', sum(amt_28), sum(gst_28)
from pharmacy_sales)) 

select gst_slab, taxable_sales,gst_collected,
round(taxable_sales/sum(taxable_sales) over()*100,2) as sales_contribution,
round(gst_collected/sum(gst_collected) over()*100,2) as gst_contrtibution
from gst_analysis_cte;

--- exempt vs taxable contribution 
select  round(sum(exempt)/ sum(tot_sale)*100,2) as exempt_pct,
round(sum(amt_5+amt_12+amt_18+amt_28+tot_gst)/ sum(tot_sale)*100,2) as taxable_pct
from pharmacy_sales;

