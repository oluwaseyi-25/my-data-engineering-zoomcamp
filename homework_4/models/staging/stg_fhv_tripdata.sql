with
    raw as (
        select * from {{ source('raw_data', 'fhv_tripdata_2019_external')}}
    ),
    renamed_and_typecasted as (
        select
            cast(dispatching_base_num as STRING) as dispatching_base_num,
            cast(pickup_datetime as TIMESTAMP) as pickup_datetime,
            cast(dropOff_datetime as TIMESTAMP) as dropoff_datetime,
            cast(PUlocationID as INTEGER) as pickup_location_id,
            cast(DOlocationID as INTEGER) as dropoff_location_id,
            cast(SR_Flag as STRING) as sr_flag,
            cast(Affiliated_base_number as STRING) as affiliated_base_number
        from raw
    )
select * from renamed_and_typecasted
where dispatching_base_num is not null

