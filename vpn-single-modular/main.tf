
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
