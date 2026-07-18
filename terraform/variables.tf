variable "project_id" {
  type        = string
  description = "The GCP Project ID where resources will be created"
}

variable "region" {
  type        = string
  description = "The region to host the cluster in"
  default     = "us-central1"
}

variable "cluster_name" {
  type    = string
  default = "devsecops-gke-cluster"
}