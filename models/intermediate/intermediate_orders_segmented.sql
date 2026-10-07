-- Uses all orders (no date filter): the 12 months before an order are needed to segment it.
WITH orders AS (
    SELECT
        order_id,
        customer_id,
        order_date
    FROM {{ ref('staging_orders') }}
),

windowed AS (
    SELECT
        *,
        -- Orders in the last N days, including every order of the same day
        COUNT(*) OVER (
            PARTITION BY customer_id
            ORDER BY UNIX_DATE(order_date)
            RANGE BETWEEN {{ var('segment_lookback_days') }} PRECEDING AND CURRENT ROW
        ) AS orders_in_window,
        -- Used to order several orders placed on the same day
        ROW_NUMBER() OVER (PARTITION BY customer_id, order_date ORDER BY order_id) AS rank_same_day,
        COUNT(*) OVER (PARTITION BY customer_id, order_date) AS orders_same_day,
        MIN(order_date) OVER () AS first_order_date
    FROM orders
),

prior AS (
    SELECT
        *,
        -- Remove the order itself and the same-day orders that come after it
        orders_in_window - (orders_same_day - rank_same_day + 1) AS prior_orders_12m
    FROM windowed
)

SELECT
    order_id,
    prior_orders_12m,
    {{ segment_label('prior_orders_12m') }} AS order_segmentation,
    DATE_SUB(order_date, INTERVAL {{ var('segment_lookback_days') }} DAY) >= first_order_date AS is_lookback_complete
FROM prior
