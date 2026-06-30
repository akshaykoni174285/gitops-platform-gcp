

resource "google_container_cluster" "gke" {
  name     = "gitops-gke"
  location = "asia-south1"

  # GKE "VPC-native" (alias IP) networking
  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  # GKE node pools are regional by default (spread across all zones in the region)
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = true #lets terraform destroy imp one 

  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name

  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  workload_identity_config {
    workload_pool = "gitops-platform-akshay-2026.svc.id.goog"
  }
}


resource "google_container_node_pool" "primary" {
  name     = "primary-pool"
  location = "asia-south1-a"
  cluster  = google_container_cluster.gke.name
  node_count = 2

  node_config {
    machine_type = "e2-medium"          # 2 vCPU, 4GB — cheap, enough for learning
    disk_size_gb = 30
    disk_type    = "pd-standard"

    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config {
      mode = "GKE_METADATA"             # required for Workload Identity
    }
  }
}