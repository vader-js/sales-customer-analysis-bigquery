CREATE OR REPLACE VIEW `sql-sales-data-500710.salespractice.product_report` AS
WITH product_base AS (
  SELECT
    p.product_id,
    p.product_number,
    p.product_name,
    p.category_id,
    p.category,
    p.subcategory,
    SUM(s.sales_amount) AS total_sales,
    SUM(s.quantity) AS qty,
    COUNT(DISTINCT s.order_number) AS total_orders,
    SAFE_DIVIDE(SUM(s.sales_amount), NULLIF(SUM(s.quantity), 0)) AS avg_selling_price,
    COUNT(DISTINCT s.customer_key) AS total_customers,
    MIN(s.order_date) AS first_order,
    MAX(s.order_date) AS last_order_date,
    DATE_DIFF(MAX(s.order_date), MIN(s.order_date), MONTH) AS lifespan,
    DATE_DIFF(CURRENT_DATE(), MAX(s.order_date), MONTH) AS recency
  FROM `sql-sales-data-500710.salespractice.dim-product` AS p
  LEFT JOIN `sql-sales-data-500710.salespractice.sales-fact` AS s
    ON p.product_key = s.product_key
  WHERE s.order_number IS NOT NULL
  GROUP BY
    p.product_id,
    p.product_number,
    p.product_name,
    p.category_id,
    p.category,
    p.subcategory
)
SELECT
  product_name,
  category_id,
  category,
  subcategory,
  CASE
    WHEN total_sales <= 10000 THEN 'Low Performer'
    WHEN total_sales <= 50000 THEN 'Mid Perfomer'
    ELSE 'High Performer'
  END AS product_segment,
  total_sales,
  total_orders,
  last_order_date,
  recency,
  lifespan,
  CASE
    WHEN lifespan = 0 THEN 0
    ELSE ROUND(SAFE_DIVIDE(total_sales, lifespan), 2)
  END AS avg_monthly_revenue,
  CASE
    WHEN total_orders = 0 THEN 0
    ELSE ROUND(SAFE_DIVIDE(total_sales, total_orders), 2)
  END AS avg_order_revenue,
  avg_selling_price,
  total_customers
FROM product_base;
