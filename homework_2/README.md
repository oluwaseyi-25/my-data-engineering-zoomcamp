### Quiz Questions and Answers

1) Within the execution for `Yellow` Taxi data for the year `2020` and month `12`: what is the uncompressed file size (i.e. the output file `yellow_tripdata_2020-12.csv` of the `extract` task)?
- [x] 128.3 MiB
- 134.5 MiB
- 364.7 MiB
- 692.6 MiB

Answer:
> I ran the flow [taxi_etl_pipeline](./my_flows/taxi_etl_pipeline.yaml) with `yellow`, `2020` and `12` as respective inputs. The `outputFile` for the extract process showed a file size of 128.3 MiB.

2) What is the rendered value of the variable `file` when the inputs `taxi` is set to `green`, `year` is set to `2020`, and `month` is set to `04` during execution?
- `{{inputs.taxi}}_tripdata_{{inputs.year}}-{{inputs.month}}.csv` 
- [x] `green_tripdata_2020-04.csv`
- `green_tripdata_04_2020.csv`
- `green_tripdata_2020.csv`

Answer:
> I ran the flow [taxi_etl_pipeline](./my_flows/taxi_etl_pipeline.yaml) with `green`, `2020` and `04` as respective inputs. The logs for the extract process under the wget command showed the fully rendered link as https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2020-04.csv.gz 

3) How many rows are there for the `Yellow` Taxi data for all CSV files in the year 2020?
- 13,537.299
- [x] 24,648,499
- 18,324,219
- 29,430,127

Answer:
> I backfilled the flow [gcp_elt_pipeline_scheduled](./my_flows/gcp_elt_pipeline_scheduled.yaml) with the yellow trigger from a start date of `2020-01-01 00:00:00` to an end date of  `2020-12-01 12:00:00`. 
> On checking the number of rows in the `yellow_tripdata` table at the bottom of the screen I observed the value of 24,648,499 rows.

4) How many rows are there for the `Green` Taxi data for all CSV files in the year 2020?
- 5,327,301
- 936,199
- [x] 1,734,051
- 1,342,034

Answer:
> I backfilled the flow [gcp_elt_pipeline_scheduled](./my_flows/gcp_elt_pipeline_scheduled.yaml) with the green trigger from a start date of `2020-01-01 00:00:00` to an end date of  `2020-12-01 12:00:00`. 
> On checking the number of rows in the `green_tripdata` table at the bottom of the screen I observed the value of 1,734,051 rows.

5) How many rows are there for the `Yellow` Taxi data for the March 2021 CSV file?
- 1,428,092
- 706,911
- [x] 1,925,152
- 2,561,031

Answer:
> I executed the flow [gcp_elt_pipeline](./my_flows/gcp_elt_pipeline.yaml) with the inputs `yellow`, `2021`, `03`. 
> On checking the number of rows in the `yellow_tripdata_2021_03` table at the bottom of the screen I observed the value of 1,925,152 rows.

6) How would you configure the timezone to New York in a Schedule trigger?
- Add a `timezone` property set to `EST` in the `Schedule` trigger configuration  
- [x] Add a `timezone` property set to `America/New_York` in the `Schedule` trigger configuration
- Add a `timezone` property set to `UTC-5` in the `Schedule` trigger configuration
- Add a `location` property set to `New_York` in the `Schedule` trigger configuration  

Answer:
> To solve this I simply looked through the documentation for the `io.kestra.plugin.core.trigger.Schedule` type and under the properties tab, I observed that the `timezone` property requests for a timezone identifier string and provided a link to a Wikipedia article; this was where I found out that the timezone identifier for New York was America/New_York.
