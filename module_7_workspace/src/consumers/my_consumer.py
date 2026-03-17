from kafka import KafkaConsumer
from my_models import ride_deserializer

kafka_server = 'localhost:9092'
topic_name = 'green-trips'


if __name__ == "__main__":
    try:
        consumer = KafkaConsumer(
            topic_name,
            bootstrap_servers = [kafka_server],
            auto_offset_reset = 'earliest',
            group_id = 'green-trips-to-postgres',
            value_deserializer = ride_deserializer
        )

        trips_gt_5 = 0
        
        for msg in consumer:
            ride = msg.value
            if ride.trip_distance > 5.0:
                trips_gt_5 += 1
                if trips_gt_5 % 500 == 0:
                    print (f'Counted {trips_gt_5} trips > 5km...')
    except KeyboardInterrupt:        
        print(f'\nCounted {trips_gt_5} trips > 5km.\n END.')