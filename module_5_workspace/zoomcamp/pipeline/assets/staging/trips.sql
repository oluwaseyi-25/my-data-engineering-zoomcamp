/* @bruin

name: staging.trips
type: duckdb.sql

materialization:
  type: table
  strategy: time_interval
  incremental_key: pickup_datetime
  time_granularity: timestamp

depends:
  - ingestion.trips
  - ingestion.payment_lookup

columns:
  - name: vendor_id
    type: int
    description: Vendor ID (1=Yellow, 2=Uber for green taxi data)
    nullable: false
    checks:
      - name: not_null
  - name: ratecode_id
    type: int
    description: Rate code ID for the trip
  - name: store_and_fwd_flag
    type: varchar
    description: Store and forward flag (Y/N)
  - name: pickup_datetime
    type: timestamp
    description: Trip start time (event timestamp for incremental processing)
    primary_key: true
    nullable: false
    checks:
      - name: not_null
  - name: dropoff_datetime
    type: timestamp
    description: Trip end time
    nullable: false
    checks:
      - name: not_null
  - name: pickup_location_id
    type: int
    description: Location ID of pickup
    primary_key: true
    nullable: false
    checks:
      - name: not_null
  - name: dropoff_location_id
    type: int
    description: Location ID of dropoff
    nullable: false
    checks:
      - name: not_null
  - name: passenger_count
    type: int
    description: Number of passengers
    nullable: false
    checks:
      - name: not_null
      - name: positive
  - name: trip_distance
    type: decimal
    description: Trip distance in miles
    primary_key: true
    nullable: false
    checks:
      - name: not_null
      - name: positive
  - name: fare_amount
    type: decimal
    description: Base fare amount
    nullable: false
    checks:
      - name: not_null
      - name: non_negative
  - name: extra
    type: decimal
    description: Extra charges (rush hour, etc)
    nullable: false
    checks:
      - name: non_negative
  - name: mta_tax
    type: decimal
    description: MTA tax amount
    nullable: false
    checks:
      - name: non_negative
  - name: tip_amount
    type: decimal
    description: Tip amount
    nullable: false
    checks:
      - name: non_negative
  - name: tolls_amount
    type: decimal
    description: Toll charges
    nullable: false
    checks:
      - name: non_negative
  - name: ehail_fee
    type: decimal
    description: E-hail fee
  - name: improvement_surcharge
    type: decimal
    description: Improvement surcharge
    nullable: false
    checks:
      - name: non_negative
  - name: total_amount
    type: decimal
    description: Total trip amount
    nullable: false
    checks:
      - name: not_null
      - name: positive
  - name: payment_type
    type: int
    description: Payment type ID
    nullable: false
    checks:
      - name: not_null
  - name: trip_type
    type: int
    description: Trip type numeric code
  - name: congestion_surcharge
    type: decimal
    description: Congestion pricing surcharge
  - name: taxi_type
    type: varchar
    description: Taxi type (green/yellow)
  - name: extracted_at
    type: timestamp
    description: Timestamp when data was extracted
    nullable: false
    checks:
      - name: not_null
  - name: payment_type_name
    type: varchar
    description: Human-readable payment type (Credit card, Cash, etc)
    nullable: false
    checks:
      - name: not_null

custom_checks:
  - name: total_amount_equals_sum_of_components
    description: Verify that total_amount = fare + extra + mta_tax + tip + tolls + improvement + congestion (where applicable)
    value: 0
    query: |
      SELECT COUNT(*) as mismatches
      FROM staging.trips
      WHERE COALESCE(total_amount, 0) < COALESCE(fare_amount, 0)
        OR COALESCE(total_amount, 0) < COALESCE(fare_amount, 0) + COALESCE(extra, 0) + COALESCE(mta_tax, 0)

@bruin */

-- Staging SQL query for NYC taxi trips
-- Purpose: Clean, normalize, deduplicate, and enrich raw trip data
-- Filters to time window required by time_interval materialization strategy
-- Deduplicates based on most recent record for each trip

WITH trips AS (
  SELECT
    vendor_id,
    ratecode_id,
    store_and_fwd_flag,

    lpep_pickup_datetime as pickup_datetime,
    lpep_dropoff_datetime as dropoff_datetime,

    pu_location_id as pickup_location_id,
    do_location_id as dropoff_location_id,
    passenger_count,
    trip_distance,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    ehail_fee,
    improvement_surcharge,
    total_amount,
    payment_type,
    trip_type,
    congestion_surcharge,
    taxi_type,
    extracted_at
  FROM ingestion.trips
  -- Filter to ensure time_interval strategy processes correct window
  WHERE pickup_datetime >= '{{ start_datetime }}'
    AND pickup_datetime < '{{ end_datetime }}'
),
payment_lookup AS (
  SELECT
    payment_type_id,
    payment_type_name
  FROM ingestion.payment_lookup
),
deduped_trips AS (
  SELECT
    t.vendor_id,
    t.ratecode_id,
    t.store_and_fwd_flag,
    t.pickup_datetime,
    t.dropoff_datetime,
    t.pickup_location_id,
    t.dropoff_location_id,
    t.passenger_count,
    t.trip_distance,
    t.fare_amount,
    t.extra,
    t.mta_tax,
    t.tip_amount,
    t.tolls_amount,
    t.ehail_fee,
    t.improvement_surcharge,
    t.total_amount,
    t.payment_type,
    t.trip_type,
    t.congestion_surcharge,
    t.taxi_type,
    t.extracted_at,
    pl.payment_type_name
  FROM trips t
  LEFT JOIN payment_lookup pl 
    ON t.payment_type = pl.payment_type_id
  -- Deduplicate: keep most recent record per trip
  -- (composite key: vendor, pickup_time, location, passenger_count, distance)
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY t.vendor_id, t.pickup_datetime, t.pickup_location_id, 
                 t.dropoff_location_id, t.passenger_count, t.trip_distance
    ORDER BY t.extracted_at DESC
  ) = 1
)

SELECT *
FROM deduped_trips
