# 1. The GKE Zonal Cluster Control Plane
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = "${var.region}-a"

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  networking_mode = "VPC_NATIVE"

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pods"
    services_secondary_range_name = "k8s-services"
  }

  # EXPLICIT DEPENDENCY: The VPC and Subnet must completely finish 
  # provisioning before GCP attempts to spin up the cluster control plane.
  depends_on = [
    google_compute_network.vpc,
    google_compute_subnetwork.subnet
  ]
}

# 2. Custom Service Account for Nodes
resource "google_service_account" "kubernetes_nodes" {
  account_id   = "${var.cluster_name}-node-sa"
  display_name = "GKE Node Service Account"
}

# 3. The Separately Managed Node Pool (Zonal)
resource "google_container_node_pool" "primary_nodes" {
  name       = "general-pool"
  location   = "${var.region}-a"
  cluster    = google_container_cluster.primary.name
  node_count = 1 # Optimized down to 1 node for your demo practice

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = false
    machine_type = "e2-medium"

    service_account = google_service_account.kubernetes_nodes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = "devsecops-demo"
    }
  }

  # EXPLICIT DEPENDENCY: The Node Pool requires BOTH the master control plane
  # and the IAM Service Account to be fully live before the VMs can join the cluster.
  depends_on = [
    google_container_cluster.primary,
    google_service_account.kubernetes_nodes
  ]
}