# Sales, Customer and Product Analysis with SQL & BigQuery

A SQL portfolio project that transforms sales transactions, customer attributes, and product attributes into reusable customer and product reporting views in Google BigQuery.

## Project objective

Build customer and product reports to explore purchasing behavior, customer segments, age groups, product performance, order activity, and revenue patterns. The report provides a foundation for business reporting and future dashboard development.

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
| `dim-product` | Product attributes joined to sales transactions in the product report |
| `customer_report` | Logical view containing the customer-level report |
| `product_report` | Product-level view defined by the supplied SQL script |

The report joins `sales-customer` to `sales-fact` on `customer_key`, then groups by customer ID and customer attributes.

## Repository contents

- [Original customer report SQL](customer_report.sql): the SELECT statement copied from the existing BigQuery logical view, preserving its logic.
- [Product report SQL](product_report.sql): the supplied CREATE OR REPLACE VIEW statement, formatted with its logic and output labels preserved.
- [Metric definitions and interpretation notes](metrics.md): formulas, segmentation rules, and current edge cases.

## How the customer query works

1. **Aggregate customer activity:** `customer_base` joins the customer, product, and sales tables and calculates sales, quantity, distinct products, distinct orders, first and last order dates, lifespan, and age.
2. **Enrich the report:** `customer_baserep` adds age groups, customer segments, recency, average order value, and average monthly spend.
3. **Select report fields:** the final SELECT returns the customer attributes and derived metrics.

## How the product query works

The `product_base` CTE joins `dim-product` to `sales-fact` on `product_key`, filters to rows with a non-null order number, and aggregates sales, quantity, distinct orders, customers, and order dates. The final SELECT assigns Low, Mid, or High performance segments and calculates average monthly revenue, average order revenue, and average selling price.

## Running the project

1. Create or use a BigQuery project and dataset.
2. Load your own compatible customer, product, and sales tables. This repository contains SQL and documentation; source data files are not included, and the original dataset's provenance has not been documented here.
3. Replace `sql-sales-data-500710.salespractice` in the SQL with your project and dataset IDs.
4. Open `customer_report.sql` in the BigQuery SQL editor and run it using GoogleSQL.
5. To create the customer view, prepend ``CREATE VIEW `YOUR_PROJECT.YOUR_DATASET.customer_report` AS`` to its SELECT statement.
6. Run `product_report.sql` to create or replace the product view in your chosen dataset. This script changes the destination view; use a new view name if you need to preserve an existing definition.

Required source columns are visible in the SQL. The query expects date-compatible `birthdate` and `order_date` values, numeric `sales_amount` and `quantity`, and compatible customer join keys.

## What this project demonstrates

The SQL produces customer and product reporting layers with demographic groupings, purchase totals, activity timing, and spending metrics. It demonstrates how to organize analysis into CTEs and convert transaction records into reusable customer-level information.

No numerical business findings or dashboard screenshots are claimed in this repository. A Tableau connection and dashboard have not yet been verified as part of this project.

## Interpretation and next steps

The customer query logic and supplied product query logic are preserved for transparency. The product script has been formatted; it has not been executed against BigQuery as part of this repository update. See [metric notes](metrics.md) for boundary behavior, date calculations, and null handling before interpreting the output. Possible extensions include explicit handling of inactive customers and unsold products, validation of segmentation thresholds, and dashboards built from the reporting views.

## Author

[Ayomide Shittu](https://github.com/vader-js)

