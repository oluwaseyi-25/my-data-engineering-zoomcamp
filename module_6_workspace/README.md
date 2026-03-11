# Module 6 Homework

## Question 1: Install Spark and PySpark

- Install Spark
- Run PySpark
- Create a local spark session
- Execute spark.version.

What's the output?

```sh
'4.1.1'
```

## Question 2: Yellow November 2025

Read the November 2025 Yellow into a Spark Dataframe.

Repartition the Dataframe to 4 partitions and save it to parquet.

What is the average size of the Parquet (ending with .parquet extension) Files that were created (in MB)? Select the answer which most closely matches.

- 6MB
- 25MB +
- 75MB
- 100MB


## Question 3: Count records

How many taxi trips were there on the 15th of November?

Consider only trips that started on the 15th of November.

- 62,610
- 102,340
- 162,604 +
- 225,768

```python
spark.sql("""
    SELECT 
        COUNT(*)
    FROM trips
    WHERE DATE(tpep_pickup_datetime) = '2025-11-15'
""").show()

>>> +--------+
    |count(1)|
    +--------+
    |  162604|
    +--------+
```


## Question 4: Longest trip

What is the length of the longest trip in the dataset in hours?

- 22.7
- 58.2
- 90.6 +
- 134.5

```python
spark.sql("""
    SELECT 
        max(round(timestampdiff(second, tpep_pickup_datetime,  tpep_dropoff_datetime)/3600, 2)) as max_trip_duration
    FROM trips
    LIMIT 100
""").show()

>>> +-----------------+
    |max_trip_duration|
    +-----------------+
    |            90.65|
    +-----------------+
```


## Question 5: User Interface

Spark's User Interface which shows the application's dashboard runs on which local port?

- 80
- 443
- 4040 +
- 8080



## Question 6: Least frequent pickup location zone

Using the zone lookup data and the Yellow November 2025 data, what is the name of the LEAST frequent pickup location Zone?

- Governor's Island/Ellis Island/Liberty Island +
- Arden Heights
- Rikers Island
- Jamaica Bay

```python
spark.sql("""
    select 
        t.PULocationID,
        z.Zone,
        count(*) as num_pickups
    from 
        trips t 
        join zones z on t.PULocationID = z.LocationID 
    group by 1, 2
    order by num_pickups
    limit 1
""").head()

>>> Row(PULocationID=105, Zone="Governor's Island/Ellis Island/Liberty Island", num_pickups=1)
```


