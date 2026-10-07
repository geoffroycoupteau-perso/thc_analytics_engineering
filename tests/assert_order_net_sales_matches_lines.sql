-- Singular test: the value of an order must match its sales lines.
-- For each order, we add up the net_sales of its lines and compare with the
-- net_sales of the order (tolerance 0.01 for rounding).
-- The test FAILS if it returns any row: each row is an order that does not match.

SELECT
    o.order_id,
    o.net_sales AS order_net_sales,
    SUM(s.net_sales) AS lines_net_sales
FROM {{ ref('staging_orders') }} AS o
INNER JOIN {{ ref('staging_sales') }} AS s USING (order_id)
GROUP BY o.order_id, o.net_sales
HAVING ABS(o.net_sales - SUM(s.net_sales)) > 0.01
