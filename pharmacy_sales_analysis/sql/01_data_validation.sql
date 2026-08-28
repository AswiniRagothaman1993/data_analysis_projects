/* Pharmacy sales analysis

File : 01_data_validation.sql

Purpose : Validate data completeness, consistency, bill numbering,
GST calculations, sales reconciliation and reporting-date patterns
before performing business analysis.

Source table - pharmacy_sales*/

--1. Row count
select count(*) as total_records from pharmacy_sales; --76

--2.a. Duplicate check for complete records
select start_bno, end_bno, bill_dt, tot_sale, exempt, amt_5, amt_12, amt_18, amt_28,
gst_5, gst_12, gst_18, gst_28, tot_gst, count(*) as duplicate_count from pharmacy_sales
group by start_bno, end_bno, bill_dt, tot_sale, exempt, amt_5, amt_12, amt_18, amt_28,
gst_5, gst_12, gst_18, gst_28, tot_gst
having count(*) >1; 

--2.b. Duplicate check for reporting periods
select bill_dt, start_bno, end_bno , count(*) as duplicate_count
from pharmacy_sales
group by bill_dt, start_bno, end_bno
having count(*) >1;  

-- No completely identical records or duplicate reporting period combinations (bill_dt, start_bno, end_bno) were identified in the dataset.

--3. NULL  value check
select count(*) filter(where bill_dt is NULL) as bill_dt,
count(*) filter (where start_bno is NULL) as start_bno,
count(*) filter (where end_bno is NULL) as end_bno,
count(*) filter (where tot_sale is NULL) as tot_sale,
count(*) filter (where exempt is NULL) as exempt,
count(*) filter (where amt_5 is NULL) as amt_5,
count(*) filter (where amt_12 is NULL) as amt_12,
count(*) filter (where amt_18 is NULL) as amt_18,
count(*) filter (where amt_28 is NULL) as amt_28,
count(*) filter (where gst_5 is NULL) as gst_5,
count(*) filter (where gst_12 is NULL) as gst_12,
count(*) filter (where gst_18 is NULL) as gst_18,
count(*) filter (where gst_28 is NULL) as gst_28,
count(*) filter (where tot_gst is NULL) as tot_gst
from pharmacy_sales; -- No NULL values in dataset

--4. Bill number continuity
with bill_number_cte as (
select bill_dt, start_bno, end_bno, lag(end_bno) over(order by bill_dt) as previous_reporting_period_end_bno
from pharmacy_sales)

select bill_dt, start_bno, previous_reporting_period_end_bno+1 as expected_start_bno, 
start_bno - (previous_reporting_period_end_bno+1) as difference,
case when start_bno  > previous_reporting_period_end_bno +1 then 'gap'
	 when start_bno <= previous_reporting_period_end_bno then 'overlap'
	 end as "date_issue"
from bill_number_cte
where start_bno >  previous_reporting_period_end_bno+1 or
	  start_bno <= previous_reporting_period_end_bno; -- no records with discontinuos bill numbers.

--5. Date coverage
select min(bill_dt) as starting_reporting_period,
max(bill_dt) as ending_reporting_period
from pharmacy_sales; --"2026-04-01"	"2026-06-30"

--6. Sales and GST reconciliation 
with reconciliation_cte as (
select tot_sale - (amt_5+amt_12+amt_18+amt_28+exempt+gst_5+gst_12+gst_18+gst_28) as sales_difference,
tot_gst - (gst_5+gst_12+gst_18+gst_28) as gst_difference
from pharmacy_sales)

select count(*) as total_records,
count(*) filter (where abs(sales_difference) > 0.01) as sales_mismatches,
count(*) filter (where abs(gst_difference) > 0.01) as gst_mismatches,
max(abs(sales_difference)) as max_sales_difference,
max(abs(gst_difference)) as max_gst_difference
from reconciliation_cte; -- 76	0	0	0.01	0.01

-- Differences up to 0.01 were treated as rounding differences.
-- No material sales or GST reconciliation discrepancies were identified.

--7. Missing dates and reporting patterns

with date_range as(
	select generate_series(
							(select min(bill_dt) from pharmacy_sales),
							(select max(bill_dt) from pharmacy_sales), 
							interval '1 day')::date as calendar_date),
missed_dates as(
select calendar_date, trim(to_char(calendar_date,'Day')) as day_name
from date_range 
where calendar_date not in (select bill_dt from pharmacy_sales))

select day_name, count(*) as number_of_periods
from missed_dates
group by day_name;
/*"Tuesday"	1
"Sunday"	13
"Friday"	1*/

-- Business rule:
-- Sundays sales are included in saturday reporting period.
-- Public holiday sales are included in preceeding reporting period.
-- Therefore, Sundays and Public holidays are expected to be absent from the source data and should not be treated as data-quality issues.





	  

