/* @bruin

# Docs:
# - SQL assets: https://getbruin.com/docs/bruin/assets/sql
# - Materialization: https://getbruin.com/docs/bruin/assets/materialization
# - Quality checks: https://getbruin.com/docs/bruin/quality/available_checks

# Asset name for daily revenue aggregation by zone
name: reports.trips_report

# DuckDB SQL asset
# Docs: https://getbruin.com/docs/bruin/assets/sql
type: duckdb.sql

# Depends on cleaned and deduplicated staging trips
depends:
  - staging.trips

# Use time_interval to rebuild only the relevant time window (matches staging layer)
materialization:
  type: table
  # Incremental strategy: refresh rows within time window
  strategy: time_interval
  # Use same incremental_key as staging for consistency
  incremental_key: report_date
  # Date granularity for daily reporting
  time_granularity: date

# Report dimensions and measures
# Aggregation level: per day per pickup zone
columns:
  - name: report_date
    type: date
    description: Date of the report (extracted from pickup_datetime)
    primary_key: true
    nullable: false
    checks:
      - name: not_null
  - name: pickup_location_id
    type: int
    description: Pickup zone location ID (dimension)
    primary_key: true
    nullable: false
    checks:
      - name: not_null
  - name: num_trips
    type: bigint
    description: Number of trips in this zone on this date
    nullable: false
    checks:
      - name: not_null
      - name: positive
  - name: total_revenue
    type: decimal
    description: Total revenue (sum of total_amount) for all trips
    nullable: false
    checks:
      - name: not_null
      - name: non_negative
  - name: avg_fare
    type: decimal
    description: Average fare amount per trip
    nullable: false
    checks:
      - name: not_null
      - name: non_negative
  - name: avg_tip
    type: decimal
    description: Average tip per trip
    nullable: false
    checks:
      - name: not_null
      - name: non_negative
  - name: avg_trip_distance
    type: decimal
    description: Average trip distance in miles
    nullable: false
    checks:
      - name: not_null
      - name: positive
  - name: avg_passenger_count
    type: decimal
    description: Average passenger count per trip
    nullable: false
    checks:
      - name: not_null
      - name: positive

@bruin */

-- Daily Revenue by Pickup Zone Report
-- Purpose: Aggregate staging trips into daily revenue metrics by zone
-- Aggregation level: pickup_location_id, report_date
--
-- Required filtering:
-- - Filter by {{ start_datetime }} / {{ end_datetime }} to match time_interval strategy
-- - This ensures Bruin deletes and rebuilds only the relevant date range

SELECT
  CAST(pickup_datetime AS DATE) AS report_date,
  pickup_location_id,
  COUNT(*) AS num_trips,
  SUM(total_amount) AS total_revenue,
  AVG(fare_amount) AS avg_fare,
  AVG(tip_amount) AS avg_tip,
  AVG(trip_distance) AS avg_trip_distance,
  AVG(passenger_count) AS avg_passenger_count
FROM staging.trips
WHERE pickup_datetime >= '{{ start_datetime }}'
  AND pickup_datetime < '{{ end_datetime }}'
GROUP BY
  CAST(pickup_datetime AS DATE),
  pickup_location_id
ORDER BY
  report_date DESC,
  total_revenue DESC
