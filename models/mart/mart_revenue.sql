-- mart_revenue 2023-03-31
{{ config(materialized='table', indexes=[{'columns':['month'],'type':'btree'}]) }}

SELECT
    DATE_TRUNC('month', order_date)   AS month,
    COUNT(DISTINCT customer_id)       AS active_customers,
    COUNT(*)                          AS total_orders,
    SUM(total_amount_usd)             AS gross_revenue,
    AVG(total_amount_usd)             AS avg_order_value
FROM {{ ref('stg_orders') }}
WHERE status = 'completed'
GROUP BY 1
ORDER BY 1
