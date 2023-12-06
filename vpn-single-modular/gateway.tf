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
