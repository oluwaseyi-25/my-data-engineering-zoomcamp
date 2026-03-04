"""@bruin
name: ingestion.trips
type: python
image: python:3.11

connection: duckdb-default

materialization:
  type: table
  strategy: append

@bruin"""

import pandas as pd
import requests
from datetime import datetime

url_base = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/{taxi_type}/{taxi_type}_tripdata_{year}-{month:02d}.csv.gz'
# url_base = 'https://d37ci6vzurychx.cloudfront.net/trip-data/{taxi_type}_tripdata_{year}-{month:02d}.parquet'

def fetch_trips(taxi_type: str, year, month) -> pd.DataFrame:
  """Download a parquet file for the given taxi type and year/month.

  The source files follow the naming convention
  `<taxi_type>_tripdata_<year>-<month>.csv.gz` under
  `https://github.com/DataTalksClub/nyc-tlc-data/releases/download`.

  We stream the content and load it into a pandas DataFrame so that the
  caller can concatenate multiple months/types together.
  """
  # build url using two-digit month
  url = url_base.format(taxi_type=taxi_type, year=year, month=month)
  resp = requests.get(url)
  resp.raise_for_status()
  # read parquet from bytes
  return pd.read_csv(pd.io.common.BytesIO(resp.content), compression='gzip')

def materialize():
    """Build a raw-trip ingestion DataFrame for the current run window.

    This function is executed by the Bruin python runtime, which sets
    several helpful environment variables.  We use the date window to
    determine which months to retrieve, and we look at the pipeline variable
    `taxi_types` (via `BRUIN_VARS`) to know which taxi classes to download.

    The output is a concatenation of every month's parquet file for every
    configured taxi type.  We do minimal processing here - we simply add a
    couple of housekeeping columns (`taxi_type` and `extracted_at`) and
    return the raw rows.  Downstream stages are responsible for deduping and
    cleaning.
    """
    import os
    import json
    from dateutil import parser

    start = os.environ.get("BRUIN_START_DATE")
    end = os.environ.get("BRUIN_END_DATE")
    if not start or not end:
        raise RuntimeError("BRUIN_START_DATE and BRUIN_END_DATE must be set")

    # parse pipeline variables JSON
    vars_json = os.environ.get("BRUIN_VARS", "{}")
    vars = json.loads(vars_json)
    taxi_types = vars.get("taxi_types", ["yellow"])

    # build list of months from start (inclusive) to end (exclusive)
    start_dt = pd.to_datetime(start)
    end_dt = pd.to_datetime(end)
    # generate month start dates
    months = pd.date_range(start=start_dt, end=end_dt, freq="MS")

    results: list[pd.DataFrame] = []
    for dt in months:
        year = dt.year
        month = dt.month
        for taxi_type in taxi_types:
            try:
                df = fetch_trips(taxi_type, year, month)
            except Exception as exc:
                # log but don't crash the entire run; might miss a month if
                # the file is not available
                print(f"warning: could not fetch {taxi_type} {year}-{month:02d}: {exc}")
                continue
            df["taxi_type"] = taxi_type
            df["extracted_at"] = datetime.utcnow().isoformat()
            results.append(df)

    if results:
        return pd.concat(results, ignore_index=True)
    else:
        # return empty dataframe with no rows if nothing was fetched
        return pd.DataFrame()


