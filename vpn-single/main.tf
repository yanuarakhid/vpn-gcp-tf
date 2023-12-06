#############################################################################
#                  Provider  Block                                                    
#############################################################################
provider "google" {
  # credentials = file("datalabs-hs-4c5de465c0d5.json")
  project = "datalabs-hs" #Project A
  # region  = "asia-southeast1"
}
#############################################################################
#             Create VPC/Subnet/Compute in First Project:  datalabs-hs                                                  
#############################################################################

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

# CREATE VPN GATEWAY

resource "google_compute_vpn_gateway" "target_gateway1" {
  name    = "cloud-gw1"
  network = google_compute_network.vpc_network_cloud.self_link
  region  = "asia-southeast1"
}

# Attach a VPN gateway to each network.
resource "google_compute_vpn_gateway" "target_gateway2" {
  name    = "on-prem-gw1"
  network = google_compute_network.vpc_network_prem.self_link
  region  = "asia-southeast2"
}

# CREATE STATIC IP 

resource "google_compute_address" "vpn_static_ip1" {
  name   = "cloud-gw1"
  region = "asia-southeast1"
}

resource "google_compute_address" "vpn_static_ip2" {
  name   = "on-prem-gw1"
  region = "asia-southeast2"
}

resource "google_compute_forwarding_rule" "fr1_esp" {
  name        = "fr1-esp"
  region      = "asia-southeast1"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_static_ip1.address
  target      = google_compute_vpn_gateway.target_gateway1.self_link
}

resource "google_compute_forwarding_rule" "fr2_esp" {
  name        = "fr2-esp"
  region      = "asia-southeast2"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_static_ip2.address
  target      = google_compute_vpn_gateway.target_gateway2.self_link
}

# The following two sets of forwarding rules are used as a part of the IPSec
# protocol
resource "google_compute_forwarding_rule" "fr1_udp500" {
  name        = "fr1-udp500"
  region      = "asia-southeast1"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_static_ip1.address
  target      = google_compute_vpn_gateway.target_gateway1.self_link
}

resource "google_compute_forwarding_rule" "fr2_udp500" {
  name        = "fr2-udp500"
  region      = "asia-southeast2"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_static_ip2.address
  target      = google_compute_vpn_gateway.target_gateway2.self_link
}

resource "google_compute_forwarding_rule" "fr1_udp4500" {
  name        = "fr1-udp4500"
  region      = "asia-southeast1"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_static_ip1.address
  target      = google_compute_vpn_gateway.target_gateway1.self_link
}

resource "google_compute_forwarding_rule" "fr2_udp4500" {
  name        = "fr2-udp4500"
  region      = "asia-southeast2"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_static_ip2.address
  target      = google_compute_vpn_gateway.target_gateway2.self_link
}

# Each tunnel is responsible for encrypting and decrypting traffic exiting
# and leaving its associated gateway
resource "google_compute_vpn_tunnel" "tunnel1" {
  name                    = "tunnel1"
  ike_version             = 2
  region                  = "asia-southeast1"
  peer_ip                 = google_compute_address.vpn_static_ip2.address
  shared_secret           = "a secret message"
  target_vpn_gateway      = google_compute_vpn_gateway.target_gateway1.self_link
  local_traffic_selector  = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]

  depends_on = [
    google_compute_forwarding_rule.fr1_udp500,
    google_compute_forwarding_rule.fr1_udp4500,
    google_compute_forwarding_rule.fr1_esp,
  ]
}

resource "google_compute_vpn_tunnel" "tunnel2" {
  name                    = "tunnel2"
  ike_version             = 2
  region                  = "asia-southeast2"
  peer_ip                 = google_compute_address.vpn_static_ip1.address
  shared_secret           = "a secret message"
  target_vpn_gateway      = google_compute_vpn_gateway.target_gateway2.self_link
  local_traffic_selector  = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]

  depends_on = [
    google_compute_forwarding_rule.fr2_udp500,
    google_compute_forwarding_rule.fr2_udp4500,
    google_compute_forwarding_rule.fr2_esp,
  ]
}


resource "google_compute_route" "route1" {
  name                = "route1"
  network             = google_compute_network.vpc_network_cloud.name
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel1.self_link
  dest_range          = "192.168.90.0/24"
  priority            = 1000
}

resource "google_compute_route" "route2" {
  name                = "route2"
  network             = google_compute_network.vpc_network_prem.name
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel2.self_link
  dest_range          = "10.0.90.0/24"
  priority            = 1000
}

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


