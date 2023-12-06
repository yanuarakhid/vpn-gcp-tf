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
