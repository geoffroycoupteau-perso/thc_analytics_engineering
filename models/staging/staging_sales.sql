SELECT
    CAST(date_date AS DATE) AS order_date,
    customer_id,
    order_id,
    products_id AS product_id,
    net_sales,
    qty AS quantity
FROM {{ source('raw', 'sales') }}
