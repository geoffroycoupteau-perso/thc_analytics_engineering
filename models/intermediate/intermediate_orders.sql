-- Intermediate: orders with their products
-- Goal: one row per order, with the number of units sold and the list of products.
-- How it works:
--   1. "lines" groups the sales lines by order: sums the quantities and
--      collects the products in an array (product_id, quantity, value).
--   2. We join this to the orders with a LEFT JOIN, so an order with no sales
--      line is kept, with qty_product = 0.
-- Used by: marts_orders and marts_orders_segmented.

WITH lines AS (
    SELECT
        order_id,
        -- One array per order: each item is one product of the order
        ARRAY_AGG(
            STRUCT(product_id, quantity, ROUND(net_sales, 2) AS total_product_sales)
            ORDER BY product_id
        ) AS products,
        SUM(quantity) AS qty_product         -- total units in the order
    FROM {{ ref('staging_sales') }}
    GROUP BY order_id
)

SELECT
    orders.order_id,
    orders.customer_id,
    orders.order_date,
    ROUND(orders.net_sales, 2) AS net_sales,
    COALESCE(lines.qty_product, 0) AS qty_product,   -- 0 if the order has no sales line
    lines.products
FROM {{ ref('staging_orders') }} AS orders
LEFT JOIN lines
    ON orders.order_id = lines.order_id
