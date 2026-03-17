import json
import dataclasses
from pandas import to_numeric
import numpy as np

from dataclasses import dataclass


@dataclass
class Ride:
    lpep_pickup_datetime: str
    lpep_dropoff_datetime: str
    PULocationID: int
    DOLocationID: int
    passenger_count: int
    trip_distance: float
    tip_amount: float
    total_amount: float


def ride_from_row(row):
    return Ride(
        lpep_pickup_datetime = str(row['lpep_pickup_datetime']),
        lpep_dropoff_datetime = str(row['lpep_dropoff_datetime']),
        PULocationID = to_numeric(row['PULocationID'], errors = 'coerce') if to_numeric(row['PULocationID'], errors = 'coerce') != np.nan else None,
        DOLocationID = to_numeric(row['DOLocationID'], errors = 'coerce') if to_numeric(row['DOLocationID'], errors = 'coerce') != np.nan else None,
        passenger_count = to_numeric(row['passenger_count'], errors = 'coerce') if to_numeric(row['passenger_count'], errors = 'coerce') != np.nan else None,
        trip_distance = to_numeric(row['trip_distance'], errors = 'coerce') if to_numeric(row['trip_distance'], errors = 'coerce') != np.nan else None,
        tip_amount = to_numeric(row['tip_amount'], errors = 'coerce') if to_numeric(row['tip_amount'], errors = 'coerce') != np.nan else None,
        total_amount = to_numeric(row['total_amount'], errors = 'coerce') if to_numeric(row['total_amount'], errors = 'coerce') != np.nan else None
    )

def ride_serializer(ride):
    ride_dict = dataclasses.asdict(ride)
    ride_json = json.dumps(ride_dict).encode('utf-8')
    return ride_json

def ride_deserializer(raw):
    ride_str = raw.decode('utf-8')
    ride_dict = json.loads(ride_str)
    return Ride(**ride_dict)