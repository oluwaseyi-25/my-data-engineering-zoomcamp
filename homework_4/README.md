# Module 4 Homework: Analytics Engineering with dbt


### Question 1. dbt Lineage and Execution

Given a dbt project with the following structure:

```
models/
├── staging/
│   ├── stg_green_tripdata.sql
│   └── stg_yellow_tripdata.sql
└── intermediate/
    └── int_trips_unioned.sql (depends on stg_green_tripdata & stg_yellow_tripdata)
```

If you run `dbt run --select int_trips_unioned`, what models will be built?

- `stg_green_tripdata`, `stg_yellow_tripdata`, and `int_trips_unioned` (upstream dependencies)
- Any model with upstream and downstream dependencies to `int_trips_unioned`
- [x] `int_trips_unioned` only
- `int_trips_unioned`, `int_trips`, and `fct_trips` (downstream dependencies)

> I ran the command and observed that I only built the model specified after the `--select` parameter
---

### Question 2. dbt Tests

You've configured a generic test like this in your `schema.yml`:

```yaml
columns:
  - name: payment_type
    data_tests:
      - accepted_values:
          arguments:
            values: [1, 2, 3, 4, 5]
```

Your model `fct_trips` has been running successfully for months. A new value `6` now appears in the source data.

What happens when you run `dbt test --select fct_trips`?

- dbt will skip the test because the model didn't change
- [x] dbt will fail the test, returning a non-zero exit code
- dbt will pass the test with a warning about the new value
- dbt will update the configuration to include the new value

> The test will fail because the addition of 6 as a new value in the source would result in the test case returning more than zero rows.
---

### Question 3. Counting Records in `fct_monthly_zone_revenue`

After running your dbt project, query the `fct_monthly_zone_revenue` model.

What is the count of records in the `fct_monthly_zone_revenue` model?

- 12,998
- 14,120
- [x] 12,184
- 15,421

---

### Question 4. Best Performing Zone for Green Taxis (2020)

Using the `fct_monthly_zone_revenue` table, find the pickup zone with the **highest total revenue** (`revenue_monthly_total_amount`) for **Green** taxi trips in 2020.

Which zone had the highest revenue?

- [x] East Harlem North
- Morningside Heights
- East Harlem South
- Washington Heights South

```sql
select 
  pickup_zone,
  sum(revenue_monthly_total_amount) as total_revenue
from `dbt_zoomcamp.fct_monthly_zone_revenue`
where extract(year from revenue_month) = 2020
and   service_type = 'Green'
and   pickup_zone in ('East Harlem North', 'Morningside Heights',  'East Harlem South', 'Washington Heights South')
group by pickup_zone
order by 2 desc limit 1
```
---

### Question 5. Green Taxi Trip Counts (October 2019)

Using the `fct_monthly_zone_revenue` table, what is the **total number of trips** (`total_monthly_trips`) for Green taxis in October 2019?

- 500,234
- 350,891
- [x] 384,624
- 421,509

```sql
select
  sum(total_monthly_trips)
from `dbt_zoomcamp.fct_monthly_zone_revenue`
where
  service_type = 'Green'
  and date(revenue_month) = date('2019-10-01')
```
---

### Question 6. Build a Staging Model for FHV Data

Create a staging model for the **For-Hire Vehicle (FHV)** trip data for 2019.

1. Load the [FHV trip data for 2019](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/fhv) into your data warehouse
2. Create a staging model `stg_fhv_tripdata` with these requirements:
   - Filter out records where `dispatching_base_num IS NULL`
   - Rename fields to match your project's naming conventions (e.g., `PUlocationID` → `pickup_location_id`)

What is the count of records in `stg_fhv_tripdata`?

- 42,084,899
- [x] 43,244,693
- 22,998,722
- 44,112,187

- I extracted and uploaded the files to gcs using the  kestra workflow:
```yaml
id: fhv_pipeline
namespace: zoomcamp.seyi

variables:
  file: "fhv_tripdata_2019-{{ taskrun.value }}.csv"
  file_uri: "gs://{{kv('GCP_BUCKET_NAME')}}/{{vars.file}}"
  bq_prefix: "{{kv('GCP_PROJECT_ID')}}.{{kv('GCP_DATASET')}}"
  table: "{{render(vars.bq_prefix)}}.fhv_tripdata_2019_{{taskrun.value}}"
  extract_table: "{{render(vars.table)}}_external"
  data: "{{ outputs.extract[taskrun.value].outputFiles['fhv_tripdata_2019-' ~ taskrun.value ~ '.csv']}}"

tasks:

  - id: loop
    type: io.kestra.plugin.core.flow.ForEach
    values: ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    tasks:
    - id: extract
      type: io.kestra.plugin.scripts.shell.Commands
      outputFiles:
        - "*.csv"
      taskRunner:
        type: io.kestra.plugin.core.runner.Process
      taskCache:
        enabled: true
      commands:
        - wget -qO- https://github.com/DataTalksClub/nyc-tlc-data/releases/download/fhv/fhv_tripdata_2019-{{ taskrun.value }}.csv.gz | gunzip > {{ render(vars.file) }}
    
    - id: upload_to_gcs_bucket
      type: io.kestra.plugin.gcp.gcs.Upload
      from: "{{render(vars.data)}}"
      to: "{{render(vars.file_uri)}}"

    - id: create_external_table
      type: io.kestra.plugin.gcp.bigquery.Query
      sql: |
        CREATE OR REPLACE EXTERNAL TABLE `{{render(vars.extract_table)}}` 
        OPTIONS (
          format = 'CSV',
          uris = [ '{{render(vars.file_uri)}}'],
          skip_leading_rows = 1,
          ignore_unknown_values = TRUE
        );

  - id: purge_files
    type: io.kestra.plugin.core.storage.PurgeCurrentExecutionFiles
    description: Delete all outputs
    disabled: false

pluginDefaults:
  - type: io.kestra.plugin.gcp
    values:
      serviceAccount: "{{secret('GCP_CREDS')}}"
      location: "{{kv('GCP_LOCATION')}}"
      bucket: "{{kv('GCP_BUCKET_NAME')}}"
      projectId: "{{kv('GCP_PROJECT_ID')}}"
```

- Then I ran this query:
```sql
CREATE OR REPLACE EXTERNAL TABLE `zoomcamp_dataset.fhv_tripdata_2019_external`
OPTIONS (
  format = 'CSV',
  uris = ['gs://tactile-zephyr-485019-m2-zoomcamp-bucket/fhv_tripdata_2019-*.csv']
);
```
- And built the model using dbt as a materialized table so I could easily see the number of rows

