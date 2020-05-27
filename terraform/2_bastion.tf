
module "bastion" {

  source               = "./modules/bastion"
  auth_token           = var.auth_token
  project_id           = var.project_id
  ssh_private_key_path = var.ssh_private_key_path
  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  cf_zone_id           = var.cf_zone_id
  ocp_version          = var.ocp_version
  ocp_version_zstream  = var.ocp_version_zstream
  depends              = [module.prepare_openshift.finished]
}

