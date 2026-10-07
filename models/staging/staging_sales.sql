-- Staging: sales lines
-- Goal: clean copy of the raw sales file. One row per product in an order.
-- What it does: renames columns and casts the date. No filter, no business logic.
-- Source: raw sales file (see source.yml).
-- Used by: intermediate_orders (to get quantities and products per order).

SELECT
    CAST(date_date AS DATE) AS order_date,   -- day the order was placed
    customer_id,
    order_id,                                -- the order this line belongs to
    products_id AS product_id,               -- the raw file calls it products_id
    net_sales,                               -- value of this product line
    qty AS quantity                          -- units of this product in the order
FROM {{ source('raw', 'sales') }}
