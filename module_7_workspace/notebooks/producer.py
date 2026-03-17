import pandas as pd

from time import sleep, time
from kafka import KafkaProducer
from models import Ride, ride_from_row, ride_serializer


topic_name = 'rides'
server = 'http://localhost:9092'
url = "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2025-11.parquet"


columns = ['PULocationID', 'DOLocationID', 'trip_distance', 'total_amount', 'tpep_pickup_datetime']

producer = KafkaProducer(
    bootstrap_servers=[server],
    value_serializer=ride_serializer
)

if __name__ == "__main__":
    
    df = pd.read_parquet(url, columns=columns).head(1000)

    
    t0 = time()

    for _, row in df.iterrows():
        ride = ride_from_row(row)
        producer.send(topic_name, value=ride)
        print("Sent:", ride)
        sleep(0.01)
    producer.flush()

    t1 = time()

    print(f'Took {t1-t0:.2f} seconds')
