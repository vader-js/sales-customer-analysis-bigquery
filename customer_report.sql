WITH
  customer_base AS (
    -- creating a base for the report with aggregation of data--
    SELECT
      concat(c.first_name, " ", c.last_name) full_name,
      c.customer_id,
      c.country,
      c.gender,
      SUM(s.sales_amount) total_sales,
      SUM(s.quantity) total_quantity,
      COUNT(DISTINCT s.product_key) total_product,
      COUNT(DISTINCT s.order_number) total_orders,
      date_diff(MAX(s.order_date), MIN(s.order_date), month) lifespan,
      date_diff(current_date(), c.birthdate, year) age,
      MAX(s.order_date) last_order,
      MIN(s.order_date) first_order
    FROM `sql-sales-data-500710.salespractice.sales-customer` AS c
    LEFT JOIN `sql-sales-data-500710.salespractice.sales-fact` AS s
      ON c.customer_key = s.customer_key
    GROUP BY
      c.birthdate, c.first_name, c.last_name, gender, country, c.customer_id
  ),
  -- using CTE, i can add some more logic to the data such as age_group and customer_segment
  customer_baserep AS (
    SELECT
      customer_id,
      country,
      gender,
      full_name,
      age,
      CASE
        WHEN age < 20 THEN "Under 20"
        WHEN age BETWEEN 20 AND 29 THEN "20-29"
        WHEN age BETWEEN 30 AND 39 THEN "30-39"
        WHEN age BETWEEN 40 AND 49 THEN "40-49"
        ELSE "50 and Above"
        END AS age_group,
      CASE
        WHEN lifespan >= 12 AND total_sales > 5000 THEN "VIP"
        WHEN lifespan >= 12 AND total_sales < 5000 THEN "Regular"
        ELSE "New"
        END AS customer_segment,
      lifespan,
      total_sales,
      total_quantity,
      total_product,
      total_orders,
      last_order,
      first_order,
      date_diff(current_date(), last_order, month) recency,
      round(safe_divide(total_sales, total_orders), 2) avg_order_value,
      round(coalesce(safe_divide(total_sales, lifespan), total_sales), 2)
        avg_monthly_spend
    FROM Customer_base
  )
SELECT
  customer_id,
  country,
  gender,
  full_name,
  age,
  age_group,
  customer_segment,
  lifespan,
  total_sales,
  total_quantity,
  total_product,
  total_orders,
  recency,
  avg_order_value,
  avg_monthly_spend
FROM customer_baserep
