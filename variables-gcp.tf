variable "gcp-region" {
  type    = "string"
  default = "australia-southeast1"
}

variable "project_id" {
  type    = "string"
  default = "matt-black-contino-project"
}

variable "service_account_iam_roles" {
  type = "list"

  default = [
    "roles/monitoring.viewer",
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter",
    "roles/storage.objectViewer", # For GCR access
  ]
}

variable "project_services" {
  type = "list"

  default = [
    "cloudresourcemanager.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
  ]
}
