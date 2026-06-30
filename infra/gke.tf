resource "google_container_cluster" "gke" {
  name     = "gitops-gke"
  location = "asia-south1-a"          # ZONAL

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  initial_node_count = 2              # the default pool IS our pool now

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 20
    disk_type    = "pd-standard"      # HDD → ZERO SSD quota usage
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  workload_identity_config {
    workload_pool = "gitops-platform-akshay-2026.svc.id.goog"
  }

  deletion_protection = false
  
  master_authorized_networks_config {
  cidr_blocks {
    cidr_block   = "10.0.0.0/20"
    display_name = "vpc-subnet-bastion"
  }
}
}

