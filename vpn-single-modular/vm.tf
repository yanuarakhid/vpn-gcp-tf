resource "google_compute_instance" "my_vm2" {
  project      = "datalabs-hs"
  zone         = "asia-southeast1-a"
  name         = "cloudvpn-1"
  machine_type = "n1-standard-1"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  # With Public IP
  network_interface {
    network = "default"
    access_config {}
  }
  network_interface {
    network    = google_compute_network.vpc_network_cloud.name
    subnetwork = google_compute_subnetwork.my-cloud-subnet.name # Replace with a reference or self link to your subnet, in quotes
  }
}

resource "google_compute_instance" "my_vm" {
  project      = "datalabs-hs"
  zone         = "asia-southeast2-b"
  name         = "premvpn-1"
  machine_type = "n1-standard-1"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  network_interface {
    network    = google_compute_network.vpc_network_prem.name
    subnetwork = google_compute_subnetwork.my-prem-subnet.name # Replace with a reference or self link to your subnet, in quotes
  }
}
