/* Project: Pharmacy Sales Analysis 
File: 03_phase2_gst_analysis.sql 
Purpose: Analyze the distribution of sales and GST collection across different GST slabs 
and compare taxable and exempt sales. 

Analysis Period: 2026-04-01 to 2026-06-30 
GST Slabs: 5%, 12%, 18%, 28%  

Source table - pharmacy_sales*/

--1. GST analysis - Taxable value and GST collected under various slabs (within 5%,12%,18%,28%)
with GST_analysis_cte as (
(select '5%' as GST_rate, sum(amt_5) as Taxable_value, sum(gst_5) as GST_collected
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

select GST_rate, Taxable_value, round(Taxable_value/sum(Taxable_value) over() *100,2) as Sales_contribution_pct,
GST_collected, round(GST_collected/sum(GST_collected) over() *100,2) as GST_contribution_pct
from GST_analysis_cte;

--2. Sales contribution by GST slab (including exempt)
with total_sales_cte as(
(select 'Exempt' as Sales_category, sum(exempt) as Total_value from pharmacy_sales)
union all
(select 'GST_5%', sum(amt_5) from pharmacy_sales)
union all
(select 'GST_12%', sum(amt_12) from pharmacy_sales)
union all
(select 'GST_18%' , sum(amt_18) from pharmacy_sales)
union all
(select 'GST_28%' , sum(amt_28) from pharmacy_sales))
select Sales_category, Total_value, round(Total_value/sum(Total_value) over()*100,2) as Sales_contribution_pct
from total_sales_cte;
/* "Exempt"	51758.41	2.55
"GST_5%"	1929289.47	94.91
"GST_12%"	0.00	    0.00
"GST_18%"	51623.89	2.54
"GST_28%"	0.00	    0.00 */

--3. exempt vs taxable contribution 
select round(sum(exempt)/ sum(tot_sale)*100,2) as exempt_pct,
round(sum(amt_5+amt_12+amt_18+amt_28+tot_gst)/ sum(tot_sale)*100,2) as taxable_pct
from pharmacy_sales;
--2.42	97.58

--4. GST summary
select sum(gst_5) as gst5_collected,
sum(gst_12) as gst12_collected,
sum(gst_18) as gst18_collected,
sum(gst_28) as gst28_collected,
sum(tot_gst) as total_gst_collected
from pharmacy_sales;

