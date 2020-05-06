provider "packet" {
  auth_token = "${var.auth_token}"
}

module "bootstrap_openshift" {
  source = "./modules/bootstrap"

  cluster_name         = "${var.cluster_name}"
  node_count           = "1"
  plan                 = "${var.plan_master}"
  facility             = "${var.facility}"
  ssh_private_key_path = "${var.ssh_private_key_path}"
  project_id           = "${var.project_id}"
}

