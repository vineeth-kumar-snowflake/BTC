{% macro convert_to_usd(column_name) %}

{{column_name}} * (
    select 
        close_price_usd as price
    from {{ ref('btc_usd_max')}}
    where to_date(replace(event_date, ' UTC', '')) = current_date() - 1
)

{% endmacro %}