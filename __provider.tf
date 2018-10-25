provider "google-beta" {
  region  = "${var.gcp-region}"
  version = "~> 1.19"
  project = "${var.project_id}"
}

provider "aws" {
  region  = "${var.aws-region}"
  version = "~> 1.40"

  assume_role {
    role_arn = "${var.aws-rolearn}"
  }
}
