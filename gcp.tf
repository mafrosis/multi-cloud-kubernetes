/*
resource "random_id" "random" {
  prefix      = "multi-"
  byte_length = "8"
}

# Create the GKE cluster service account
resource "google_service_account" "gke" {
  account_id   = "gke"
  display_name = "Multi GKE"
}

# Add the service account to the project
resource "google_project_iam_member" "service-account" {
  count   = "${length(var.service_account_iam_roles)}"
  role    = "${element(var.service_account_iam_roles, count.index)}"
  member  = "serviceAccount:${google_service_account.gke.email}"
}

# Enable required services on the project
resource "google_project_service" "service" {
  count   = "${length(var.project_services)}"
  service = "${element(var.project_services, count.index)}"

  # Do not disable the service on destroy
  disable_on_destroy = false
}

resource "google_compute_network" "vpc" {
  name                    = "${random_id.random.hex}-vpc"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"

  depends_on = ["google_project_service.service"]
}

resource "google_compute_subnetwork" "service_subnet" {
  name          = "${random_id.random.hex}-subnet"
  ip_cidr_range = "10.100.0.0/24"
  network       = "${google_compute_network.vpc.self_link}"

  # access PaaS without external IP
  private_ip_google_access = true
}

# Allow inbound traffic on 8200
resource "google_compute_firewall" "multi-inbound" {
  name    = "${random_id.random.hex}-multi-inbound"
  network = "${google_compute_network.vpc.self_link}"

  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = [
    "110.174.101.135/32",
  ]
}

# Get latest cluster version
data "google_container_engine_versions" "versions" {
  zone = "${var.gcp-region}-a"
}

# Create the GKE cluster
resource "google_container_cluster" "multi" {
  name = "multi"
  zone = "${var.gcp-region}-a"

  min_master_version = "${data.google_container_engine_versions.versions.latest_master_version}"
  node_version       = "${data.google_container_engine_versions.versions.latest_node_version}"

  # Deploy into VPC
  network    = "${google_compute_subnetwork.service_subnet.network}"
  subnetwork = "${google_compute_subnetwork.service_subnet.self_link}"

  # Private GKE
  private_cluster        = true
  master_ipv4_cidr_block = "172.16.0.32/28"
  ip_allocation_policy   = {
    cluster_ipv4_cidr_block = "/20"
    services_ipv4_cidr_block = "/22"
  }

  # Hosts authorized to connect to the cluster master
  master_authorized_networks_config = {
    cidr_blocks = [
      {
        cidr_block = "110.174.101.135/32",
        display_name = "Matt Home"
      },
    ]
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Declare node pools independently of clusters
  remove_default_node_pool = true

  node_pool = {
    name = "default-pool"
  }

  # Ensure cluster is not recreated when pool configuration changes
  lifecycle = {
    ignore_changes = ["node_pool"]
  }
}

resource "google_container_node_pool" "multi" {
  name    = "default-pool"
  cluster = "${google_container_cluster.multi.name}"
  zone    = "${var.gcp-region}-a"

  initial_node_count = "1"

  max_pods_per_node = "110" # Kubernetes default

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    image_type      = "COS"
    machine_type    = "n1-standard-2"
    service_account = "${google_service_account.gke.email}"

    workload_metadata_config {
      node_metadata = "SECURE"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    tags = ["multi"]
  }

  depends_on = [
    "google_project_service.service",
    "google_project_iam_member.service-account",
  ]
}

output "multi_service_account" {
  value = "${google_service_account.gke.email}"
}
*/
