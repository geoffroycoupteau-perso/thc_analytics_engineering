WITH lines AS (
    SELECT
        order_id,
        ARRAY_AGG(
            STRUCT(product_id, quantity, ROUND(net_sales, 2) AS total_product_sales)
            ORDER BY product_id
        ) AS products,
        SUM(quantity) AS qty_product
    FROM {{ ref('staging_sales') }}
    GROUP BY order_id
)

SELECT
    orders.order_id,
    orders.customer_id,
    orders.order_date,
    ROUND(orders.net_sales, 2) AS net_sales,
    COALESCE(lines.qty_product, 0) AS qty_product,
    lines.products
FROM {{ ref('staging_orders') }} AS orders
LEFT JOIN lines
    ON orders.order_id = lines.order_id
