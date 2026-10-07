SELECT
    CAST(date_date AS DATE) AS order_date,
    customers_id AS customer_id,
    orders_id AS order_id,
    net_sales
FROM {{ source('raw', 'orders') }}
