/* Project: Pharmacy Sales Analysis 
File: 04_phase4_day_of_week_analysis.sql 

Purpose: Analyze sales performance by day of the week to identify 
weekday-level patterns in sales, bill volume and average bill value. 

Analysis Scope: Individual reporting days only. 
Reason: Accumulated reporting days, particularly Saturday, 
combine sales from multiple calendar days and therefore can distort normal weekday comparisons. 

Metrics: - Total Bills - Total Sales - Average Bill Value */

--1. day of week performance 

select day_number, trim(day_name) as day_name, count(*) as reporting_periods, 
sum(tot_sale) as total_sales, sum(bill_counts) as total_bill_counts,
round(sum(tot_sale)/sum(bill_counts),2) as avg_bill_value,
round(avg(tot_sale),2) as avg_sales_per_period
from pharmacy_sales_view
where "Reporting day type" = 'Individual day'
group by day_number, day_name
order by day_number ;






