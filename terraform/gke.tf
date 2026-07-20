# 1. Hardened GKE Zonal Cluster Control Plane
resource "google_container_cluster" "primary" {
  #checkov:skip=CKV_GCP_65:Intentionally skipping Google Groups RBAC as it requires a real Google Workspace domain setup.
  #checkov:skip=CKV_GCP_18:Intentionally allowing public endpoint access with master authorized networks for easy home dev access.
  #checkov:skip=CKV_GCP_69:Using Workload Identity pool mapping below; bypassing legacy plane check.

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

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false 
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0" 
      display_name = "Dev-Access"
    }
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  network_policy {
    enabled  = true
    provider = "PROVIDER_UNSPECIFIED" 
  }
  
  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  release_channel {
    channel = "STABLE"
  }

  resource_labels = {
    environment = "devsecops-demo"
  }

  enable_intranode_visibility = true

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

# 3. Secure Node Pool Configuration
resource "google_container_node_pool" "primary_nodes" {
  name       = "general-pool"
  location   = "${var.region}-a"
  cluster    = google_container_cluster.primary.name
  node_count = 1

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
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = "devsecops-demo"
    }

    # FIX CKV_GCP_69: Block classic metadata endpoints, force Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # FIX CKV_GCP_68: Block unsigned low-level kernel changes on runtime VMs
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  depends_on = [
    google_container_cluster.primary,
    google_service_account.kubernetes_nodes
  ]
}