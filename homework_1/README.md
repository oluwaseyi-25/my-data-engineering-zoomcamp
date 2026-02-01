## Question 1. Understanding Docker images

Run docker with the `python:3.13` image. Use an entrypoint `bash` to interact with the container.

What's the version of `pip` in the image?

- [x] 25.3 
- 24.3.1
- 24.2.1
- 23.3.1

Commands:
```bash
docker run -it --rm --entrypoint=bash python:3.13

pip --version
```

## Question 2. Understanding Docker networking and docker-compose

Given the following `docker-compose.yaml`, what is the `hostname` and `port` that pgadmin should use to connect to the postgres database?

```yaml
services:
  db:
    container_name: postgres
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: 'postgres'
      POSTGRES_PASSWORD: 'postgres'
      POSTGRES_DB: 'ny_taxi'
    ports:
      - '5433:5432'
    volumes:
      - vol-pgdata:/var/lib/postgresql/data

  pgadmin:
    container_name: pgadmin
    image: dpage/pgadmin4:latest
    environment:
      PGADMIN_DEFAULT_EMAIL: "pgadmin@pgadmin.com"
      PGADMIN_DEFAULT_PASSWORD: "pgadmin"
    ports:
      - "8080:80"
    volumes:
      - vol-pgadmin_data:/var/lib/pgadmin

volumes:
  vol-pgdata:
    name: vol-pgdata
  vol-pgadmin_data:
    name: vol-pgadmin_data
```

- postgres:5433
- localhost:5432
- db:5433
- [x] postgres:5432
- [x] db:5432

If multiple answers are correct, select any 

## Question 3. Counting short trips

For the trips in November 2025 (lpep_pickup_datetime between '2025-11-01' and '2025-12-01', exclusive of the upper bound), how many trips had a `trip_distance` of less than or equal to 1 mile?

- 7,853
- [x] 8,007
- 8,254
- 8,421


Query: 
```sql
SELECT
	count(1) as "count"
FROM
	green_trip_data
WHERE
	"lpep_pickup_datetime" >= '2025-11-01' 
	AND "lpep_pickup_datetime" < '2025-12-01'
	AND trip_distance <= 1.0;
```


## Question 4. Longest trip for each day

Which was the pick up day with the longest trip distance? Only consider trips with `trip_distance` less than 100 miles (to exclude data errors).

Use the pick up time for your calculations.

- [x] 2025-11-14
- 2025-11-20
- 2025-11-23
- 2025-11-25

Query: 
```sql
SELECT
	DATE("lpep_pickup_datetime") AS "day with longest trip"
FROM green_trip_data
WHERE trip_distance < 100
ORDER BY trip_distance DESC
LIMIT 1;
```


## Question 5. Biggest pickup zone

Which was the pickup zone with the largest `total_amount` (sum of all trips) on November 18th, 2025?

- [x] East Harlem North
- East Harlem South
- Morningside Heights
- Forest Hills

Query: 
```sql
SELECT
	z."Zone",
	SUM(total_amount) AS "total_amount"
FROM
	green_trip_data t
	INNER JOIN zones z ON t."PULocationID" = z."LocationID"
WHERE 
	DATE("lpep_pickup_datetime") = '2025-11-18'
GROUP BY z."Zone"
ORDER BY "total_amount" DESC
LIMIT 1;
```


## Question 6. Largest tip

For the passengers picked up in the zone named "East Harlem North" in November 2025, which was the drop off zone that had the largest tip?

Note: it's `tip` , not `trip`. We need the name of the zone, not the ID.

- JFK Airport
- [x] Yorkville West
- East Harlem North
- LaGuardia Airport

Query: 
```sql
SELECT
	zdo."Zone",
	SUM(tip_amount) AS tip
FROM
	GREEN_TRIP_DATA T
	INNER JOIN zones zpu ON T."PULocationID" = zpu."LocationID"
	INNER JOIN zones zdo ON T."DOLocationID" = zdo."LocationID"
WHERE 
	zpu."Zone" = 'East Harlem North'
	AND zdo."Zone" IN ('JFK Airport', 'Yorkville West', 'East Harlem North', 'LaGuardia Airport')
	AND "lpep_pickup_datetime" >= '2025-11-01'
	AND "lpep_pickup_datetime" < '2025-12-01'
GROUP BY zdo."Zone"
ORDER BY tip DESC
LIMIT 1;
```
PS: `Upper East Side North` was the Drop-off zone with the largest tip.

## Question 7. Terraform Workflow

Which of the following sequences, respectively, describes the workflow for:
1. Downloading the provider plugins and setting up backend,
2. Generating proposed changes and auto-executing the plan
3. Remove all resources managed by terraform`

Answers:
- terraform import, terraform apply -y, terraform destroy
- teraform init, terraform plan -auto-apply, terraform rm
- terraform init, terraform run -auto-approve, terraform destroy
- [x] terraform init, terraform apply -auto-approve, terraform destroy
- terraform import, terraform apply -y, terraform rm
