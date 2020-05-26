module "bootstrap_openshift" {
  source = "./modules/bootstrap"

  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  node_count           = 1
  count_compute        = var.count_compute
  count_master         = var.count_master
  plan                 = var.plan_master
  facility             = var.facility
  ssh_private_key_path = var.ssh_private_key_path
  project_id           = var.project_id
  cf_zone_id           = var.cf_zone_id
  bastion_ip           = module.bastion.nginx_ip
  depends              = [module.bastion.finished]
}

