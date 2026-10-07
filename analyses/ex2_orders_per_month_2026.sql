-- Exercise 2: number of orders per month in 2026
SELECT
    EXTRACT(MONTH FROM order_date) AS month,
    COUNT(*) AS orders
FROM {{ ref('marts_orders') }}
WHERE EXTRACT(YEAR FROM order_date) = 2026
GROUP BY month
ORDER BY month
