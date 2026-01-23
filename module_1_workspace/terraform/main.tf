terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.6.0"
    }
  }
}

variable "google_credentials" {
  type        = string
  description = "Path to the gcp service account credentials"
  sensitive   = true
}

provider "google" {
  project     = "tactile-zephyr-485019-m2"
  region      = "us-central1"
  credentials = var.google_credentials

}

resource "google_storage_bucket" "auto_expire" {
  name          = "tactile-zephyr-485019-m2-bucket"
  location      = "US"
  force_destroy = true
}

resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id = "seyis_first_dataset"
}
