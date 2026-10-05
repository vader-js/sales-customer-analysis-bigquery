# Sales and Customer Analysis with SQL & BigQuery

A SQL portfolio project by **Ayomide Shittu** that transforms sales transactions and customer attributes into a reusable customer reporting view in Google BigQuery.

## Project objective

Build a customer-level report to explore purchasing behavior, customer segments, age groups, order activity, and spending patterns. The report provides a foundation for business reporting and future dashboard development.

## Tools and SQL techniques

- Google BigQuery and GoogleSQL
- Common table expressions (CTEs)
- LEFT JOIN to combine customer and transaction data
- SUM, COUNT DISTINCT, MIN, and MAX aggregations
- CASE expressions for age bands and customer segments
- DATE_DIFF for customer lifespan and recency
- SAFE_DIVIDE, COALESCE, and ROUND for spending metrics

## Data model

The BigQuery project contains the `salespractice` dataset with these objects:

| Object | Role |
| --- | --- |
| `sales-customer` | Customer attributes, including customer keys, names, country, gender, and birthdate |
| `sales-fact` | Sales transactions, including order dates, order numbers, sales amounts, quantities, and product keys |
| `dim-product` | Product dimension table present in the dataset; not used by the customer report query |
| `customer_report` | Logical view containing the customer-level report |

The report joins `sales-customer` to `sales-fact` on `customer_key`, then groups by customer ID and customer attributes.

## Repository contents

- [Original customer report SQL](customer_report.sql): the SELECT statement copied from the existing BigQuery logical view, preserving its logic.
- [Metric definitions and interpretation notes](metrics.md): formulas, segmentation rules, and current edge cases.

## How the query works

1. **Aggregate customer activity:** `customer_base` joins the customer and sales tables and calculates sales, quantity, distinct products, distinct orders, first and last order dates, lifespan, and age.
2. **Enrich the report:** `customer_baserep` adds age groups, customer segments, recency, average order value, and average monthly spend.
3. **Select report fields:** the final SELECT returns the customer attributes and derived metrics.

## Running the project

1. Create or use a BigQuery project and dataset.
2. Load your own compatible customer and sales tables. This repository contains SQL and documentation; source data files are not included, and the original dataset's provenance has not been documented here.
3. Replace `sql-sales-data-500710.salespractice` in the SQL with your project and dataset IDs.
4. Open `customer_report.sql` in the BigQuery SQL editor and run it using GoogleSQL.
5. To create a reusable view, prepend ``CREATE VIEW `YOUR_PROJECT.YOUR_DATASET.customer_report` AS`` to the SELECT statement.

Required source columns are visible in the SQL. The query expects date-compatible `birthdate` and `order_date` values, numeric `sales_amount` and `quantity`, and compatible customer join keys.

## What this project demonstrates

The SQL produces a customer reporting layer with demographic groupings, purchase totals, activity timing, and spending metrics. It demonstrates how to organize analysis into CTEs and convert transaction records into reusable customer-level information.

No numerical business findings or dashboard screenshots are claimed in this repository. A Tableau connection and dashboard have not yet been verified as part of this project.

## Interpretation and next steps

The original SQL is preserved for transparency. See [metric notes](metrics.md) for boundary behavior, date calculations, and null handling before interpreting the output. Possible extensions include product analysis using `dim-product`, explicit handling of inactive customers, validation of segmentation thresholds, and a dashboard built from the reporting view.

## Author

[Ayomide Shittu](https://github.com/vader-js)
