terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0" # Using major version 6 for modern functionality
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}