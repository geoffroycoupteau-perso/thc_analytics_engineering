{% macro segment_label(prior_orders_col) %}
    CASE
        WHEN {{ prior_orders_col }} = 0 THEN 'New'
        WHEN {{ prior_orders_col }} <= {{ var('segment_returning_max_prior_orders') }} THEN 'Returning'
        ELSE 'VIP'
    END
{% endmacro %}
