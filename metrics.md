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

# Product report metrics

These definitions describe `product_report.sql`, supplied by the author and formatted without changing its business logic.

| Field | Calculation or meaning |
| --- | --- |
| `product_name`, `category_id`, `category`, `subcategory` | Product attributes |
| `total_sales` | Sum of sales amount for rows with a non-null order number |
| `total_orders` | Count of distinct order numbers |
| `last_order_date` | Most recent order date |
| `recency` | Month boundaries between last order date and CURRENT_DATE |
| `lifespan` | Month boundaries between first and last order dates |
| `avg_monthly_revenue` | Zero for zero-month lifespan; otherwise total sales divided by lifespan, rounded to two decimals |
| `avg_order_revenue` | Zero for zero orders; otherwise total sales divided by distinct order count, rounded to two decimals |
| `avg_selling_price` | Total sales divided by total quantity, with safe division and a zero-denominator guard; not rounded in the supplied SQL |
| `total_customers` | Count of distinct customer keys |

## Product segmentation

- **Low Performer:** total sales at or below 10,000.
- **Mid Perfomer:** total sales above 10,000 and at or below 50,000. The supplied output label contains this spelling and is preserved.
- **High Performer:** all remaining cases, normally total sales above 50,000.

The currency is not specified, so thresholds use dataset units.

## Product interpretation notes

- `WHERE s.order_number IS NOT NULL` removes unmatched products after the LEFT JOIN. Unsold products and sales with null order numbers are excluded.
- A NULL total sales value falls through to High Performer under the current CASE expression.
- Products with zero-month lifespan receive zero monthly revenue, even when they have positive sales; this differs from the customer report's fallback.
- `product_id`, `product_number`, `qty`, and `first_order` are computed or grouped in the CTE but are not returned by the final SELECT.
- Distinct product IDs are used in grouping but omitted from the output; products sharing names may appear as separate rows without an exposed unique product identifier.
- Calendar-boundary month calculations and dynamic CURRENT_DATE affect lifespan and recency interpretation.
- Duplicate product join keys can inflate sums; source-key uniqueness should be validated.

The script includes CREATE OR REPLACE VIEW. It was added to the repository without running it or replacing the live BigQuery view.
