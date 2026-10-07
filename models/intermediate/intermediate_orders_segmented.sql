-- Intermediate: segment of each order (New, Returning, VIP)
-- Goal: for each order, count the orders the same customer placed in the
-- 12 months before it, then turn that number into a segment.
-- Rules (thresholds are variables in dbt_project.yml):
--   0 orders before    -> New
--   1 to 3 orders      -> Returning
--   4 or more orders   -> VIP
-- Important: this model reads ALL orders, with no date filter. The 12 months
-- before an order are needed, so an order of January 2026 must see 2025.
-- The filter on 2026 is done later, in marts_orders_segmented.
-- Used by: marts_orders_segmented.

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
        -- Step 1: orders of this customer in the last N days (N = segment_lookback_days).
        -- This count includes the order itself and every order of the same day.
        COUNT(*) OVER (
            PARTITION BY customer_id
            ORDER BY UNIX_DATE(order_date)
            RANGE BETWEEN {{ var('segment_lookback_days') }} PRECEDING AND CURRENT ROW
        ) AS orders_in_window,
        -- Step 2: if a customer places several orders on the same day, we put them
        -- in order by order_id. The second one then counts the first as an earlier order.
        ROW_NUMBER() OVER (PARTITION BY customer_id, order_date ORDER BY order_id) AS rank_same_day,
        COUNT(*) OVER (PARTITION BY customer_id, order_date) AS orders_same_day,
        MIN(order_date) OVER () AS first_order_date
    FROM orders
),

prior AS (
    SELECT
        *,
        -- Step 3: remove the order itself and the same-day orders that come after it.
        -- What is left is the number of orders BEFORE this one.
        orders_in_window - (orders_same_day - rank_same_day + 1) AS prior_orders_12m
    FROM windowed
)

-- Final result: one row per order
SELECT
    order_id,
    prior_orders_12m,
    {{ segment_label('prior_orders_12m') }} AS order_segmentation,
    -- False when the 12 months before the order start before our first data day.
    -- The data starts on 2025-07-09, so the segment can be wrong before 2026-07-09.
    DATE_SUB(order_date, INTERVAL {{ var('segment_lookback_days') }} DAY) >= first_order_date AS is_lookback_complete
FROM prior
