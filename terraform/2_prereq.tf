
module "prepare_openshift" {

  source = "./modules/prereq"

  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  ocp_version          = var.ocp_version
  count_master         = var.count_master
  count_compute        = var.count_compute
  ssh_public_key_path  = var.ssh_public_key_path
  ssh_private_key_path = var.ssh_private_key_path
  bastion_ip           = module.bastion.lb_ip
  ocp_api_token        = var.ocp_cluster_manager_token
  depends              = [module.bastion.finished]
}

