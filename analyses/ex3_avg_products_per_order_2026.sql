-- Exercise 3: average number of products per order, per month in 2026
-- "Products" means units sold (qty_product).
SELECT
    EXTRACT(MONTH FROM order_date) AS month,
    ROUND(AVG(qty_product), 2) AS avg_products_per_order
FROM {{ ref('marts_orders') }}
WHERE EXTRACT(YEAR FROM order_date) = 2026
GROUP BY month
ORDER BY month
