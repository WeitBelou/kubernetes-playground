resource "google_compute_network" "kubernetes" {
  name = "kubernetes"
}

resource "google_compute_firewall" "deny_all_egress" {
  name    = "deny-all-egress"
  network = "${google_compute_network.kubernetes.name}"

  priority = 1200

  direction = "EGRESS"

  deny {
    protocol = "all"
  }
}

resource "google_compute_firewall" "allow_network_egress" {
  name    = "allow-network-egress"
  network = "${google_compute_network.kubernetes.name}"

  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  destination_ranges = ["${var.subnetwork_cidr}"]
}

resource "google_compute_firewall" "allow_ansible_controller_egress" {
  name    = "allow-ansible-controller-egress"
  network = "${google_compute_network.kubernetes.name}"

  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443", "80"]
  }

  target_tags = ["ansible-controller"]
}

resource "google_compute_firewall" "allow_ssh_ansible_controller" {
  name    = "allow-ssh-ansible-controller"
  network = "${google_compute_network.kubernetes.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${var.trusted_ip_ranges}"]
  target_tags   = ["ansible-controller"]
}

resource "google_compute_firewall" "allow_ssh_from_controller_to_kubernetes" {
  name    = "allow-ssh-from-controller-to-kubernetes"
  network = "${google_compute_network.kubernetes.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["ansible-controller"]
  target_tags = ["kubernetes-master"]
}