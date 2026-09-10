/* Project: Pharmacy Sales Analysis 
File: 04_phase3_monthly_analysis.sql 
Purpose: Analyze monthly sales performance and compare each month's performance with the previous month. 
Metrics: Total Bills , Total Sales, Total GST Collected , Average Bill Value , Month-over-Month Growth

Analysis Period: 2026-04-01 to 2026-06-30 

Source table - pharmacy_sales*/

--1. Monthly performance 
create view monthly_analysis_view as (
select extract(Month from bill_dt) as month_number, to_char(bill_dt,'Month') as month_name,
sum(tot_sale) as monthly_sales,
sum(end_bno-start_bno+1):: numeric as monthly_bill_counts,
sum(tot_gst) as monthly_gst_collected,
round(sum(tot_sale)/sum(end_bno-start_bno+1),2) as monthly_avg_bill_value
from pharmacy_sales
group by extract(Month from bill_dt), to_char(bill_dt,'Month')
order by month_number)

select * from monthly_analysis_view;

--2. previous month comparison 
select month_number, month_name,monthly_sales, lag(monthly_sales) over(order by month_number) as prev_month_sale,
monthly_bill_counts, lag(monthly_bill_counts) over(order by month_number) as prev_month_bill_counts,
monthly_gst_collected, lag(monthly_gst_collected) over(order by month_number) as prev_month_gst_collected,
monthly_avg_bill_value, lag(monthly_avg_bill_value) over(order by month_number) as prev_month_avg_bill_value
from monthly_analysis_view;

--3. Month-over-month comparison
with previous_month_cte as (
select month_number, month_name,monthly_sales, lag(monthly_sales) over(order by month_number) as prev_month_sale,
monthly_bill_counts, lag(monthly_bill_counts) over(order by month_number) as prev_month_bill_counts,
monthly_gst_collected, lag(monthly_gst_collected) over(order by month_number) as prev_month_gst_collected,
monthly_avg_bill_value, lag(monthly_avg_bill_value) over(order by month_number) as prev_month_avg_bill_value
from monthly_analysis_view)

select month_number, month_name, 
(monthly_sales-prev_month_sale) as sales_difference, round((monthly_sales-prev_month_sale)/ prev_month_sale*100,2) as sales_growth_pct,
(monthly_bill_counts-prev_month_bill_counts) as bill_count_difference, 
round((monthly_bill_counts-prev_month_bill_counts)/prev_month_bill_counts*100,2) as bill_count_growth_pct,
(monthly_gst_collected-prev_month_gst_collected) as gst_collected_difference,
round((monthly_gst_collected-prev_month_gst_collected)/prev_month_gst_collected*100,2) as gst_collected_growth_pct,
(monthly_avg_bill_value-prev_month_avg_bill_value) as avg_bill_value_difference,
round((monthly_avg_bill_value-prev_month_avg_bill_value)/prev_month_avg_bill_value*100,2) as avg_bill_value_growth_pct
from previous_month_cte