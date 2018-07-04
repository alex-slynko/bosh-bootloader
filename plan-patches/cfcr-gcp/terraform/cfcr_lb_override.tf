resource "google_compute_address" "cfcr_tcp" {
  name = "${var.env_id}-cfcr"
}

resource "google_compute_target_pool" "cfcr_tcp_public" {
    region = "${var.region}"
    name = "${var.env_id}-cfcr-tcp-public"
}

resource "google_compute_forwarding_rule" "cfcr_tcp" {
  name        = "${var.env_id}-cfcr-tcp"
  target      = "${google_compute_target_pool.cfcr_tcp_public.self_link}"
  port_range  = "8443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.cfcr_tcp.address}"
  health_checks = ["${google_compute_health_check.default.self_link}"]
}

resource "google_compute_health_check" "default" {
  name               = "${var.env_id}-k8s-master"
  tcp_health_check {
    port = 8443
  }
  check_interval_sec = 2
  timeout_sec        = 2
}


resource "google_compute_firewall" "cfcr_tcp_public" {
  name    = "${var.env_id}-cfcr-tcp-public"
  network       = "${google_compute_network.bbl-network.name}"

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  target_tags = ["master"]
}
