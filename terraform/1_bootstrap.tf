provider "packet" {
  auth_token = "${var.auth_token}"
}

 
provider "cloudflare" {
  email   = "${var.cf_email}"
  api_key = "${var.cf_api_key}"
}

module "bootstrap_openshift" {
  source = "./modules/bootstrap"

  cluster_name         = "${var.cluster_name}"
  node_count           = "1"
  plan                 = "${var.plan_master}"
  facility             = "${var.facility}"
  ssh_private_key_path = "${var.ssh_private_key_path}"
  project_id           = "${var.project_id}"
  cf_zone_id           = "${var.cf_zone_id}"

}

