resource "google_compute_instance" "my_vm2" {
  project      = "datalabs-hs"
  zone         = "us-central1-c"
  name         = "cloudvpn-1"
  machine_type = "n1-standard-1"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  # With Public IP
  #   network_interface {
  #     network    = google_compute_network.network1.name
  #     subnetwork = google_compute_subnetwork.network1_subnet1.name # Replace with a reference or self link to your subnet, in quotes
  #   }
  network_interface {
    network    = google_compute_network.network1.name
    subnetwork = google_compute_subnetwork.network1_subnet2.name # Replace with a reference or self link to your subnet, in quotes
  }
}

resource "google_compute_instance" "my_vm" {
  project      = "datalabs-hs"
  zone         = "us-central1-b"
  name         = "premvpn-1"
  machine_type = "n1-standard-1"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  #   network_interface {
  #     network    = google_compute_network.network2.name
  #     subnetwork = google_compute_subnetwork.network2_subnet1.name # Replace with a reference or self link to your subnet, in quotes
  #   }
  network_interface {
    network    = google_compute_network.network2.name
    subnetwork = google_compute_subnetwork.network2_subnet2.name # Replace with a reference or self link to your subnet, in quotes
  }
}
