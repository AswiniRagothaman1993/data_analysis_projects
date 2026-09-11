# Pharmacy Sales & GST Analysis

## Project Overview

This project analyzes three months of pharmacy sales data from April 2026 to June 2026 using PostgreSQL and Power BI.

The objective is to understand sales performance, transaction volume, average bill value, monthly trends, weekday patterns and GST contribution, 
while accounting for the pharmacy's real-world reporting practices.

The analysis combines SQL-based data validation and transformation with Power BI-based data modeling, DAX calculations, and dashboard development.

## Business Objective

The analysis aims to answer the following business questions:

- What factors were associated with changes in sales?
- How did sales and bill volume change across the three months?
- How does average bill value relate to sales?
- What GST slabs contribute most to sales and GST collection?
- Are there any unusual patterns in the reporting dates that need to be considered when interpreting daily sales?
- Which weekdays showed stronger or weaker performance?- 
- Which reporting dates recorded the highest and lowest sales?


## Dataset

The dataset contains aggregated pharmacy sales information for:

**April 2026 – June 2026**

After validation and removal of extra-period records, the dataset contains:

- **76 reporting records**
- **8,224 bills**
- **₹21,38,428.54 total sales**
- **₹1,05,756.70 total GST**

### Key Columns

| Column | Description |
|---|---|
| START_NO | Starting bill number for the reporting period |
| END_BNO | Ending bill number for the reporting period |
| BILL_DT | Pharmacy reporting date |
| TOT_SALE | Total sales including GST |
| EXEMPT | Sales exempt from GST |
| AMT_5 | Taxable sales under 5% GST |
| AMT_12 | Taxable sales under 12% GST |
| AMT_18 | Taxable sales under 18% GST |
| AMT_28 | Taxable sales under 28% GST |
| GST_5 | GST collected at 5% |
| GST_12 | GST collected at 12% |
| GST_18 | GST collected at 18% |
| GST_28 | GST collected at 28% |
| TOT_GST | Total GST collected |



## Important Data Consideration

The source system does not provide individual bill-level transactions.

The data is available as aggregated reporting-period summaries containing a bill-number range and total sales/GST values.

Therefore, this analysis focuses on:

- Reporting-period performance
- Bill volume
- Average bill value
- Monthly trends
- Weekday patterns
- GST contribution
- Relationships between sales, bill volume and average bill value

It does not attempt to analyze individual products, customers, prescriptions or individual bills.


## Real-World Reporting Challenge

An important business rule was identified during validation.

The pharmacy does not always report each calendar day's sales separately.

The reporting process follows these rules:

- Sunday sales are included in Saturday's reporting.
- If Monday is a public holiday, those sales are included in Saturday's reporting.
- If Thursday is a public holiday, those sales are included in Wednesday's reporting.

As a result, some calendar dates are absent from the dataset.

The missing dates were investigated against the business reporting rules rather than being incorrectly treated as missing data.

Because of this, `BILL_DT` is interpreted as a **reporting date** rather than assuming that every row represents exactly one calendar day's sales.


## Tools & Technologies

- **PostgreSQL** – Data validation, transformation and analysis
- **Power BI** – Data modeling and visualization
- **DAX** – Measures and analytical calculations
- **Excel** – Initial source format / data inspection
- **GitHub** – Project version control and documentation


# SQL Analysis

The SQL analysis was performed in multiple phases.

## Data Overview & Validation

Validation checks included:

- Row count
- Duplicate records
- NULL and blank values
- Bill-number continuity
- Sales reconciliation
- GST reconciliation
- Reporting-date patterns

### Validation Results

- Total records: **76**
- Duplicate records: **0**
- Blank/NULL issues: **0**
- Sales reconciliation mismatches: **0**
- GST reconciliation mismatches: **0**

A maximum ₹0.01 difference was observed in some reconciliation calculations due to rounding.

## Phase 1 — Overall Performance

- Total sales: **2138428.54**
- Total bills: **8224**
- Total exempt sales: **51758.41**
- Total taxable sales: **1980913.36**
- Total GST: **105756.77**  
- Average bill value: **260.02**


## Phase 2 — Sales Drivers

Reporting dates were classified into:

- **Individual day**
- **Accumulated day**

This classification was created based on the presence or absence of the following reporting date and the pharmacy's reporting rules.

### Individual-day highlights

**Highest sales**

- Date: June 1, 2026
- Sales: ₹35,015.50
- Bills: 117
- Average bill value: ₹299.28

**Lowest sales**

- Date: May 20, 2026
- Sales: ₹11,337.77
- Bills: 52
- Average bill value: ₹218.03

**Highest average bill value**

- Date: May 6, 2026
- Average bill value: ₹338.34

**Lowest average bill value**

- Date: June 23, 2026
- Average bill value: ₹199.40

The relationship between sales and two key metrics was analyzed:

1. Bill volume
2. Average bill value

Both showed positive relationships with sales.

For individual reporting days, the correlation between bill count and sales was approximately **0.74**.

The analysis uses correlation to identify relationships and does not interpret correlation as causation.


## Phase 3 — Monthly Performance

Monthly sales, bill volume and average bill value were analyzed.

### Key observations

**April → May**

- Bill volume: **−0.07%**
- Sales: **+6.38%**
- Average bill value: **+6.46%**

May sales increased while bill volume remained almost unchanged, associated with a higher average bill value.

**May → June**

- Bill volume: **+0.62%**
- Sales: **−7.87%**
- Average bill value: **−8.44%**

June sales declined despite a slight increase in bill volume, associated with a lower average bill value.


## Phase 4 — Day of Week Analysis

Weekday performance was analyzed using **Individual day** reporting periods.

### Key findings

- **Thursday** recorded the strongest individual-day performance.
- Thursday had the highest average sales per reporting period: **₹25,344.77**
- Thursday also had the highest average bill value: **₹270.58**
- **Friday** recorded the weakest individual-day performance.
- Friday had the lowest average sales per reporting period: **₹20,025.56**
- Friday also had the lowest average bill value: **₹240.55**

Weekday differences in sales were associated with differences in both bill volume and average bill value.

# Phase 5 - GST Analysis

GST contribution was analyzed across the 5%, 12%, 18% and 28% slabs.

The **5% GST slab dominates the recorded GST collection**.

The 12% and 28% GST columns contain no recorded contribution in this dataset.

### Sales contribution

| Category | Contribution |
|---|---:|
| 5% GST | 94.73% |
| 18% GST | 2.85% |
| Exempt | 2.42% |
| 12% GST | 0% |
| 28% GST | 0% |

The **5% GST slab dominates the recorded taxable sales**.

GST contribution to sales is 4.95%.  

---


# 📈 Power BI Dashboard

The Power BI dashboard contains five pages.

### Page 1 — Overall Performance

Provides an executive-level view of:

- Total Sales
- Total GST
- Total Bills
- Average Bill Value
- Monthly sales and bill volume
- Weekday sales
- Overall key findings

### Page 2 — Sales Trend & Drivers

Analyzes:

- Daily sales trend
- Sales vs total bills
- Sales vs average bill value
- Highest/lowest sales dates
- Highest/lowest bill-count dates
- Highest/lowest average bill-value dates

A reporting-day-type filter allows analysis of individual and accumulated reporting periods.

### Page 3 — Monthly Performance

Analyzes:

- Monthly sales
- Monthly bill volume
- Monthly average bill value
- Month-over-month sales growth
- Month-over-month bill growth
- Month-over-month average bill value growth

### Page 4 — Day-of-Week Analysis

Analyzes:

- Day-wise total sales
- Average sales per reporting period
- Bill count
- Average bill value
- Individual-day weekday performance

### Page 5 — GST Analysis

Analyzes:

- GST collected by slab
- Sales contribution by GST slab
- Monthly GST by slab
- Total GST
- GST as a percentage of total sales


---

# Key Business Findings

1. **May sales increased by 6.38%**, while bill volume remained almost unchanged. The increase was associated with a **6.46% increase in average bill value**.

2. **June sales declined by 7.87%** despite a slight increase in bill volume. The decline was associated with an **8.44% decrease in average bill value**.

3. **Thursday was the strongest individual weekday**, with the highest average sales per reporting period and highest average bill value.

4. **Friday was the weakest individual weekday**, with the lowest average sales per reporting period and lowest average bill value.

5. The **5% GST slab accounted for 94.73% of sales contribution**, making it the dominant GST category in the dataset.

6. Sales showed positive relationships with both **bill volume** and **average bill value**.

7. The pharmacy's reporting practices result in selected Sundays and public holidays being incorporated into earlier reporting dates. This business rule was identified and incorporated into the analysis rather than treating those dates as unexplained missing data.

---

# Limitations

The dataset has several limitations:

- Data is aggregated at reporting-period level.
- Individual bill-level analysis is not possible.
- Product-level analysis is not available.
- Customer-level analysis is not available.
- The dataset covers only three months.
- Missing calendar dates are partly explained by the pharmacy's reporting process.
- Correlation analysis identifies relationships but does not establish causation.

Therefore, the findings should be interpreted as descriptive and exploratory insights from the available reporting data.

---

# Project Outcome

This project demonstrates an end-to-end data analysis workflow:

**Raw Data → Data Validation → Business Rule Identification → SQL Analysis → Data Modeling → DAX → Power BI Dashboard → Business Insights**

The project focuses not only on visualization but also on understanding the underlying business reporting process and ensuring that analytical conclusions are based on validated data.

---

