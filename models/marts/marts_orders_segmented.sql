{{
    config(
        partition_by={'field': 'order_date', 'data_type': 'date', 'granularity': 'month'} if var('use_partitioning') else none,
        cluster_by=['customer_id', 'order_segmentation']
    )
}}

SELECT
    orders.order_date,
    orders.customer_id,
    orders.order_id,
    orders.net_sales,
    segments.order_segmentation
FROM {{ ref('intermediate_orders') }} AS orders
INNER JOIN {{ ref('intermediate_orders_segmented') }} AS segments
    ON orders.order_id = segments.order_id
WHERE orders.order_date BETWEEN '{{ var("segmented_start_date") }}' AND '{{ var("segmented_end_date") }}'
