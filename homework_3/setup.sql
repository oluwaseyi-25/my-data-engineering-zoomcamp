-- TEMPLATE FOR EACH MONTH'S EXTERNAL TABLE
CREATE EXTERNAL TABLE  `<DATASET_ID>.yellow_tripdata_2024_<MONTH>`
OPTIONS(
    format = 'PARQUET',
    uris = ['gs://<gcs_file_uri>']
)

-- MATERIALIZED TABLE FROM INDIVIDUAL FILES
CREATE TABLE `<DATASET_ID>.yellow_tripdata_2024`
AS 
SELECT
  VendorID,
  tpep_pickup_datetime,
  tpep_dropoff_datetime,
  passenger_count,
  trip_distance,
  RatecodeID,
  store_and_fwd_flag,
  PULocationID,
  DOLocationID,
  payment_type,
  fare_amount,
  extra,
  mta_tax,
  tip_amount,
  tolls_amount,
  improvement_surcharge,
  total_amount,
  congestion_surcharge
FROM `zoomcamp_dataset.yellow_tripdata_2024_01`

UNION ALL 

SELECT
  VendorID,
  tpep_pickup_datetime,
  tpep_dropoff_datetime,
  passenger_count,
  trip_distance,
  RatecodeID,
  store_and_fwd_flag,
  PULocationID,
  DOLocationID,
  payment_type,
  fare_amount,
  extra,
  mta_tax,
  tip_amount,
  tolls_amount,
  improvement_surcharge,
  total_amount,
  congestion_surcharge
FROM `zoomcamp_dataset.yellow_tripdata_2024_02`

UNION ALL 

SELECT
  VendorID,
  tpep_pickup_datetime,
  tpep_dropoff_datetime,
  passenger_count,
  trip_distance,
  RatecodeID,
  store_and_fwd_flag,
  PULocationID,
  DOLocationID,
  payment_type,
  fare_amount,
  extra,
  mta_tax,
  tip_amount,
  tolls_amount,
  improvement_surcharge,
  total_amount,
  congestion_surcharge
FROM `zoomcamp_dataset.yellow_tripdata_2024_03`

UNION ALL 

SELECT
  VendorID,
  tpep_pickup_datetime,
  tpep_dropoff_datetime,
  passenger_count,
  trip_distance,
  RatecodeID,
  store_and_fwd_flag,
  PULocationID,
  DOLocationID,
  payment_type,
  fare_amount,
  extra,
  mta_tax,
  tip_amount,
  tolls_amount,
  improvement_surcharge,
  total_amount,
  congestion_surcharge
FROM `zoomcamp_dataset.yellow_tripdata_2024_04`

UNION ALL 

SELECT
  VendorID,
  tpep_pickup_datetime,
  tpep_dropoff_datetime,
  passenger_count,
  trip_distance,
  RatecodeID,
  store_and_fwd_flag,
  PULocationID,
  DOLocationID,
  payment_type,
  fare_amount,
  extra,
  mta_tax,
  tip_amount,
  tolls_amount,
  improvement_surcharge,
  total_amount,
  congestion_surcharge
FROM `zoomcamp_dataset.yellow_tripdata_2024_05`

UNION ALL 

SELECT
  VendorID,
  tpep_pickup_datetime,
  tpep_dropoff_datetime,
  passenger_count,
  trip_distance,
  RatecodeID,
  store_and_fwd_flag,
  PULocationID,
  DOLocationID,
  payment_type,
  fare_amount,
  extra,
  mta_tax,
  tip_amount,
  tolls_amount,
  improvement_surcharge,
  total_amount,
  congestion_surcharge
FROM `zoomcamp_dataset.yellow_tripdata_2024_06`;
