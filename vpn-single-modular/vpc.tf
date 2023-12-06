resource "google_compute_network" "vpc_network_cloud" {
  name                    = "cloud"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_network" "vpc_network_prem" {
  name                    = "prem"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "my-cloud-subnet" {
  name          = "cloud-subnet"
  ip_cidr_range = "10.0.90.0/24"
  network       = google_compute_network.vpc_network_cloud.name
  region        = "asia-southeast1"
}

resource "google_compute_subnetwork" "my-prem-subnet" {
  name          = "prem-subnet"
  ip_cidr_range = "192.168.90.0/24"
  network       = google_compute_network.vpc_network_prem.name
  region        = "asia-southeast2"
}
