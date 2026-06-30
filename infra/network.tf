# 1. The VPC — global, custom mode (we define subnets ourselves)
resource "google_compute_network" "vpc" {
  name                    = "gitops-vpc"
  auto_create_subnetworks = false   # custom mode (not auto-subnet-everywhere)
}

# 2. The regional subnet — ONE subnet covers all zones in asia-south1
resource "google_compute_subnetwork" "subnet" {
  name          = "gitops-subnet"
  region        = "asia-south1"
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.0.0/20"          # node IPs

  # secondary ranges for GKE "VPC-native" — pods & services get their own IPs
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.16.0.0/14"
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.20.0.0/20"
  }

  private_ip_google_access = true        # private nodes can reach Google APIs w/o external IP
}

# 3. Cloud Router — Cloud NAT needs this to operate
resource "google_compute_router" "router" {
  name    = "gitops-router"
  region  = "asia-south1"
  network = google_compute_network.vpc.id
}

# 4. Cloud NAT — outbound internet for private (no-external-IP) nodes
resource "google_compute_router_nat" "nat" {
  name                               = "gitops-nat"
  router                             = google_compute_router.router.name
  region                             = "asia-south1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# 5. Firewall — allow nodes/pods to talk to each other internally
resource "google_compute_firewall" "allow_internal" {
  name    = "gitops-allow-internal"
  network = google_compute_network.vpc.name

  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }

  source_ranges = ["10.0.0.0/20", "10.16.0.0/14", "10.20.0.0/20"]
}