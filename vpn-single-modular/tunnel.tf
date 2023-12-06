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
