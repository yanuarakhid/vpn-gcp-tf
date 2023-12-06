#############################################################################
#                 multiple Provider  Block                                                    
#############################################################################
provider "google" {
  # credentials = file("datalabs-hs-4c5de465c0d5.json")
  project = "datalabs-hs" #Project A
  region  = "asia-southeast1"
}
#############################################################################
#             Create VPC/Subnet/Compute in First Project:  datalabs-hs                                                  
#############################################################################

resource "google_compute_network" "vpc1-akhid" {
  name                    = "my-custom-network-1"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "my-custom-subnet1" {
  name          = "my-custom-subnet-1"
  ip_cidr_range = "10.255.210.0/24"
  network       = google_compute_network.vpc1-akhid.name
  region        = "asia-southeast1"
}

resource "google_compute_instance" "my_vm" {
  project      = "datalabs-hs"
  zone         = "asia-southeast1-b"
  name         = "demo-1"
  machine_type = "n1-standard-1"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = "my-custom-network-1"
    subnetwork = google_compute_subnetwork.my-custom-subnet1.name # Replace with a reference or self link to your subnet, in quotes
  }
}


#############################################################################
#        Create second VPC/Subnet/compute in first Project:  datalabs-hs                                                                  #
#############################################################################


resource "google_compute_network" "vpc2-akhid" {
  name                    = "my-custom-network-2"
  auto_create_subnetworks = "false"
}


resource "google_compute_subnetwork" "my-custom-subnet2" {
  name          = "my-custom-subnet-2"
  ip_cidr_range = "10.255.215.0/24"
  network       = google_compute_network.vpc2-akhid.name
  region        = "asia-southeast2"

}

resource "google_compute_instance" "my_vm2" {
  project      = "datalabs-hs"
  zone         = "asia-southeast2-b"
  name         = "demo-2"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = "my-custom-network-2"
    subnetwork = google_compute_subnetwork.my-custom-subnet2.name # Replace with a reference or self link to your subnet, in quotes
  }
}


#############################################################################
#     Peering vpc1-akhid <--> VPC2-akhid  and     vpc1-akhid <--> VPC3                                                             #
#############################################################################

resource "google_compute_network_peering" "peering1" {
  name         = "peering1"
  network      = google_compute_network.vpc1-akhid.self_link
  peer_network = google_compute_network.vpc2-akhid.self_link
}

resource "google_compute_network_peering" "peering2" {
  name         = "peering2"
  network      = google_compute_network.vpc2-akhid.self_link
  peer_network = google_compute_network.vpc1-akhid.self_link
}


resource "google_compute_firewall" "rules" {
  project = "datalabs-hs"
  name    = "allow-ssh"
  network = "my-custom-network-1" # Replace with a reference or self link to your network, in quotes
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["35.235.240.0/20", "10.255.215.0/24"]
}
##### create  Firewall to allow icmp from VPC1 to VPC2. such that on network VPC2
resource "google_compute_firewall" "allow-icmp-rule-vpc2" {
  project = "datalabs-hs"
  name    = "allow-icmp"
  network = "my-custom-network-2" # Replace with a reference or self link to your network, in quotes
  # allow {
  #   protocol = "tcp"
  #   ports    = ["22"]
  # }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["10.255.210.0/24"]
}

# # Create IAP SSH permissions for your test instance

# resource "google_project_iam_member" "project" {
#   project = "datalabs-hs"
#   role    = "roles/iap.tunnelResourceAccessor"
#   member  = "serviceAccount:teraform-user1@host-project-375410.iam.gserviceaccount.com"
# }
