terraform {
    required_providers {
      google = {
        source = "hashicorp/google"
        version = "5.6.0"
      }
    }
}

variable "GOOGLE_CREDS" {
  description = "The service account credentials file path"
  type = string
  sensitive = true
}

provider "google" {
  project = "tactile-zephyr-485019-m2"
  region = "europe-west2"
  credentials = var.GOOGLE_CREDS
}

resource "google_storage_bucket" "loaded_bucket" {
    name = "tactile-zephyr-485019-m2-zoomcamp-bucket"
    location = "europe-west2"
    storage_class = "REGIONAL"
    force_destroy = true
}

resource "google_bigquery_dataset" "loaded_dataset" {
    dataset_id = "zoomcamp_dataset"
    location = "europe-west2"
    delete_contents_on_destroy = true
}