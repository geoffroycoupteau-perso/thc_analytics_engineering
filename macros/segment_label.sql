{#
    segment_label(prior_orders_col)

    Turns a number of previous orders into a segment name.
    Argument: the column with the number of orders the customer placed
    in the 12 months before the order.

    Result:
        0                                   -> 'New'
        1 up to segment_returning_max_prior_orders (default 3) -> 'Returning'
        more than that                      -> 'VIP'

    The threshold is the variable segment_returning_max_prior_orders in
    dbt_project.yml, so it can be changed in one place.
#}
{% macro segment_label(prior_orders_col) %}
    CASE
        WHEN {{ prior_orders_col }} = 0 THEN 'New'
        WHEN {{ prior_orders_col }} <= {{ var('segment_returning_max_prior_orders') }} THEN 'Returning'
        ELSE 'VIP'
    END
{% endmacro %}
