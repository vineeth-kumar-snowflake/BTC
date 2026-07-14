{{ config(materialized='incremental', incremental_strategy='append')}}


with flattened_outputs as (

select
tx.HASH_KEY, 
tx.block_number, 
tx.block_timestamp, 
tx.is_coinbase,
f.value:address::string as output_address,
f.value:value::float as output_value

from {{ ref('stg_btc')}} tx,
lateral flatten(input => outputs) f  --flatten is used to explode an array into multiple rows. here 'input =>' is part of syntax 

where f.value:address is not null

{% if is_incremental() %}

and tx.block_timestamp >= (select max(tx.block_timestamp) from {{ this }})

{% endif %}
)

select 
HASH_KEY, 
block_number, 
block_timestamp, 
is_coinbase, 
output_address, 
output_value
from 
flattened_outputs
