"""Template for building a `dlt` pipeline to ingest data from a REST API."""

import dlt
from dlt.sources.rest_api import rest_api_resources
from dlt.sources.rest_api.typing import RESTAPIConfig
from dlt.sources.helpers.rest_client.paginators import PageNumberPaginator


@dlt.source
def taxi_pipeline_rest_api_source():
    """Define dlt resources from NYC taxi REST API endpoints."""
    config: RESTAPIConfig = {
        "client": {
            "base_url": "https://us-central1-dlthub-analytics.cloudfunctions.net/",
        },
        "resource_defaults": {
            # "primary_key": "id",
            "write_disposition": "replace"
        },
        "resources": [
            {
                "name": "trips_endpoint",
                "endpoint": {
                    "path": "data_engineering_zoomcamp_api",
                    "paginator": {
                        "type": "page_number",
                        "page_param": "page",
                        "base_page": 1,
                        "total_path": None,
                        "stop_after_empty_page": True
                    },
                },
            }
        ],
    }

    yield from rest_api_resources(config)


pipeline = dlt.pipeline(
    pipeline_name='taxi_pipeline',
    destination='duckdb',
    # `refresh="drop_sources"` ensures the data and the state is cleaned
    # on each `pipeline.run()`; remove the argument once you have a
    # working pipeline.
    refresh="drop_sources",
    # show basic progress of resources extracted, normalized files and load-jobs on stdout
    progress="log",
)


if __name__ == "__main__":
    load_info = pipeline.run(taxi_pipeline_rest_api_source())
    # print(load_info)  # noqa: T201
