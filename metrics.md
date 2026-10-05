# Customer report metrics

These definitions describe the original SQL in `customer_report.sql`.

| Field | Calculation or meaning |
| --- | --- |
| `customer_id` | Customer identifier from the customer table |
| `country`, `gender`, `full_name` | Customer attributes; full name concatenates first and last names |
| `age` | Year boundaries between birthdate and CURRENT_DATE |
| `age_group` | Under 20, 20–29, 30–39, 40–49, or 50 and Above |
| `total_sales` | Sum of sales amount |
| `total_quantity` | Sum of quantity |
| `total_product` | Count of distinct purchased product keys |
| `total_orders` | Count of distinct order numbers |
| `lifespan` | Month boundaries between first and last order dates |
| `recency` | Month boundaries between last order date and CURRENT_DATE |
| `avg_order_value` | Total sales divided by distinct order count, rounded to two decimals |
| `avg_monthly_spend` | Total sales divided by lifespan, falling back to total sales when division returns NULL; rounded to two decimals |

## Customer segmentation

- **VIP:** lifespan is at least 12 months and total sales exceed 5,000.
- **Regular:** lifespan is at least 12 months and total sales are below 5,000.
- **New:** all remaining cases.

The sales currency is not specified in the SQL, so the threshold is expressed in dataset units.

## Current interpretation notes

- Exactly 5,000 in sales falls into **New**, even for customers with a lifespan of at least 12 months, because the original CASE uses strict greater-than and less-than comparisons.
- Customers with no matching transactions remain in the report because of the LEFT JOIN. Their distinct counts are zero; sums and dates may be NULL. They fall into **New** under the current segment rules.
- A missing birthdate produces a NULL age but falls into **50 and Above** through the age CASE's ELSE branch.
- DATE_DIFF with YEAR or MONTH counts calendar boundaries; age is not necessarily completed birthday age, and month metrics are not elapsed days divided by 30.
- CURRENT_DATE makes age and recency change over time, even when source transactions stay unchanged.
- Zero-month lifespan makes SAFE_DIVIDE return NULL, so monthly spend falls back to total sales. This is the implemented fallback, not a measured monthly rate.
- Grouping includes customer attributes as well as customer ID. Inconsistent customer dimension records may produce more than one report row for a customer ID, and duplicated join keys may inflate totals.

These are observations about the preserved query, not changes to the source BigQuery view. Before production use, validate join-key uniqueness, nulls, boundary cases, and the intended business definitions.
