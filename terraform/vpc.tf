# Create the custom VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
}

# Create a subnet within the VPC
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.cluster_name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.0.0/19" # Main subnet range for nodes

  # Secondary ranges for VPC-Native GKE (Required for modern clusters)
  secondary_ip_range {
    range_name    = "k8s-pods"
    ip_cidr_range = "172.16.0.0/14"
  }

  secondary_ip_range {
    range_name    = "k8s-services"
    ip_cidr_range = "172.20.0.0/18"
  }
}