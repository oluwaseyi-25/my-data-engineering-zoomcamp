import pandas as pd

from time import sleep, time
from kafka import KafkaProducer
from my_models import Ride, ride_serializer, ride_from_row

dataset_url = 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-10.parquet'
columns = [
             "lpep_pickup_datetime",
             "lpep_dropoff_datetime",
             "PULocationID",
             "DOLocationID",
             "passenger_count",
             "trip_distance",
             "tip_amount",
             "total_amount",
          ]


kafka_server = "localhost:9092"
topic_name = 'green-trips'

producer = KafkaProducer(
    bootstrap_servers = [kafka_server],
    value_serializer = ride_serializer
)

if __name__ == "__main__":
    df = pd.read_parquet(dataset_url, columns=columns)
    
    t0 = time()
    for i, row in df.iterrows():
        ride = ride_from_row(row)
        producer.send (topic_name, value = ride)
        # print(f'Sent: {ride}...')
        # sleep(0.5)
        
    producer.flush()
    
    t1 = time()
    time_elapsed = f'{t1-t0:.2f} seconds'
    print(f'Time taken to send {df.shape[0]} rows: {time_elapsed}.')
    