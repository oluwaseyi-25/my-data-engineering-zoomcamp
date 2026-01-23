# base image to build image from
FROM python:3.13.11-slim

# multi-stage / container build
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

# set work directory to directory with source code
# volume maps here
WORKDIR /code

# add virtual environment to PATH variable to make it accessible
ENV PATH="/code/.venv/bin:$PATH"

# Copy UV environment descriptor files
COPY "pyproject.toml" "uv.lock" ".python-version" ./

# Install dependencies (instead if pip install)
RUN uv sync --locked

# Copy source code
COPY zoomcamp_ingestion.py ingest_data.py

ENTRYPOINT ["python", "ingest_data.py"]