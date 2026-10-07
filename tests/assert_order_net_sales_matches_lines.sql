-- Fails for orders whose net_sales differs from the sum of their sales lines (tolerance 0.01).
SELECT
    o.order_id,
    o.net_sales AS order_net_sales,
    SUM(s.net_sales) AS lines_net_sales
FROM {{ ref('staging_orders') }} AS o
INNER JOIN {{ ref('staging_sales') }} AS s USING (order_id)
GROUP BY o.order_id, o.net_sales
HAVING ABS(o.net_sales - SUM(s.net_sales)) > 0.01
