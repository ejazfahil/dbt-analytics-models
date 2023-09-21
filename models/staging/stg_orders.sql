-- stg_orders 2023-09-21
{{ config(materialized='view') }}

SELECT
    order_id::TEXT                    AS order_id,
    customer_id::TEXT                 AS customer_id,
    order_date::DATE                  AS order_date,
    status::TEXT                      AS status,
    total_amount::NUMERIC             AS total_amount_usd,
    _loaded_at                        AS loaded_at
FROM {{ source('raw', 'orders') }}
WHERE order_id IS NOT NULL
