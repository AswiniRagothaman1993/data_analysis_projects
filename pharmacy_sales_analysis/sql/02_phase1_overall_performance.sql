/* Pharmacy sales analysis

File : 02_phase1_overall_performance.sql

Purpose : Measure the overall sales performance of the pharmacy during the three-month analysis period.

Source table - pharmacy_sales*/

--1. Overall performance
with overall_performance_cte as(
select bill_dt as reporting_dt,
start_bno, end_bno, (end_bno-start_bno+1) as bill_counts,
tot_sale, exempt, (amt_5+amt_12+amt_18+amt_28) as taxable_value,tot_gst
from pharmacy_sales)

select 
sum(bill_counts) as total_bills,
sum(tot_sale) as total_sales,
sum(exempt) as total_exempt_sales,
sum(taxable_value) as total_taxable_value,
sum(tot_gst) as total_gst,
round(sum(tot_sale)/sum(bill_counts),2) as avg_bill_value
from overall_performance_cte;

-- 8224	2138428.54	51758.41	1980913.36	105756.77	260.02


