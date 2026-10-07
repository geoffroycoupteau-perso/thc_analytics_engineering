-- Exercise 1: number of orders in 2026
SELECT COUNT(*) AS orders
FROM {{ ref('marts_orders') }}
WHERE EXTRACT(YEAR FROM order_date) = 2026
