
resource "google_project_service" "iap" {
  service            = "iap.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "gitops-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["bastion"]

}



resource "google_compute_instance" "bastion" {
  name         = "gitops-bastion"
  machine_type = "e2-small"
  zone         = "asia-south1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-standard" # HDD → no SSD quota
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
  }

  tags = ["bastion"]

  service_account {
    scopes = ["cloud-platform"] # lets the VM use your identity for GKE
  }
  metadata = {
    enable-oslogin = "TRUE"
  }
}
