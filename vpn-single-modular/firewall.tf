# CREATE FIREWALL RULES

resource "google_compute_firewall" "fw_network_cloud" {
  name    = "cloud-fw"
  network = google_compute_network.vpc_network_cloud.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "5001"]
  }

  allow {
    protocol = "udp"
    ports    = ["5001"]
  }
  source_ranges = ["35.235.240.0/20", "192.168.90.0/24"]
}

resource "google_compute_firewall" "fw_network_prem" {
  name    = "prem-fw"
  network = google_compute_network.vpc_network_prem.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "5001"]
  }

  allow {
    protocol = "udp"
    ports    = ["5001"]
  }
  source_ranges = ["35.235.240.0/20", "10.0.90.0/24"]
}
