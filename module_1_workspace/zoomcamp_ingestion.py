import pandas as pd
from sqlalchemy import create_engine
from tqdm.auto import tqdm # For progress bars
import click

# read a sample of data

dtypes = {
    "VendorID": "Int64",
    "passenger_count": "Int64",
    "trip_distance": "float64",
    "RatecodeID": "Int64",
    "store_and_fwd_flag": "string",
    "PULocationID": "Int64",
    "DOLocationID": "Int64",
    "payment_type": "Int64",
    "fare_amount": "float64",
    "extra": "float64",
    "mta_tax": "float64",
    "tip_amount": "float64",
    "tolls_amount": "float64",
    "improvement_surcharge": "float64",
    "total_amount": "float64",
    "congestion_surcharge": "float64"
}

parse_dates = [
    "tpep_pickup_datetime",
    "tpep_dropoff_datetime"
]

@click.command()
@click.option('--user', default='root', help='PostgreSQL user')
@click.option('--password', default='root', help='PostgreSQL password')
@click.option('--host', default='localhost', help='PostgreSQL host')
@click.option('--port', default=5432, type=int, help='PostgreSQL port')
@click.option('--database', default='ny_taxi', help='PostgreSQL database name')
@click.option('--table', default='yellow_taxi_data', help='Target table name')
@click.option('--year', default=2021, help='Target table name')
@click.option('--month', default=1, help='Target table name')
def ingest_data(user, password, host, port, database, table, year, month):
    prefix = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/'
    url = f"{prefix}yellow_tripdata_{year}-{month:02d}.csv.gz"
    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{database}')

    # we create an iterator to effectively work with large datasets
    df_iter = pd.read_csv(
        url,
        dtype=dtypes,
        parse_dates=parse_dates,
        iterator=True,
        chunksize=100000
    )

    first = True
    for df_chunk in tqdm(df_iter):
        if first:
            first = False
            df_chunk.head(0).to_sql(
                name=table,
                con=engine,
                if_exists='replace'
            )
            print('Table created')

        df_chunk.to_sql(
            name=table,
            con=engine,
            if_exists='append'
        )

        print(f"Inserted chunk with {len(df_chunk)} rows")

if __name__ == "__main__":
    ingest_data()


