-- int_customer_ltv 2023-07-07
{{ config(materialized='table') }}

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }} WHERE status = 'completed'
),
customer_totals AS (
    SELECT
        customer_id,
        COUNT(*)                      AS n_orders,
        SUM(total_amount_usd)         AS lifetime_value,
        MIN(order_date)               AS first_order_date,
        MAX(order_date)               AS last_order_date,
        MAX(order_date) - MIN(order_date) AS tenure_days
    FROM orders
    GROUP BY customer_id
)
SELECT *, lifetime_value / NULLIF(n_orders,0) AS avg_order_value
FROM customer_totals
