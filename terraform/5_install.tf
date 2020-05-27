module "openshift_install" {
  source               = "./modules/install"

  ssh_private_key_path = var.ssh_private_key_path
  bastion_ip           = module.bastion.nginx_ip
  count_master         = var.count_master
  count_compute        = var.count_compute
  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain

  depends              = [module.openshift_masters.node_ip]

}

