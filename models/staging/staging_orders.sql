-- Staging: orders
-- Goal: clean copy of the raw orders file. One row per order.
-- What it does: renames columns and casts the date. No filter, no business logic.
-- Source: raw orders file (see source.yml).
-- Used by: intermediate_orders, intermediate_orders_segmented, and the tests.

SELECT
    CAST(date_date AS DATE) AS order_date,   -- day the order was placed
    customers_id AS customer_id,             -- the raw file calls it customers_id
    orders_id AS order_id,                   -- the raw file calls it orders_id
    net_sales                                -- total value of the order
FROM {{ source('raw', 'orders') }}
