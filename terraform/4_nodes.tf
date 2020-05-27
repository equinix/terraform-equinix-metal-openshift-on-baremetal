module "openshift_masters" {
  source = "./modules/node"

  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  node_count           = var.count_master
  plan                 = var.plan_master
  facility             = var.facility
  ssh_private_key_path = var.ssh_private_key_path
  project_id           = var.project_id
  cf_zone_id           = var.cf_zone_id
  bastion_ip           = module.bastion.nginx_ip
  node_type            = "master"
  depends              = [module.bootstrap_openshift.bootstrap_ip]
}

module "openshift_workers" {
  source = "./modules/node"

  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  node_count           = var.count_compute
  plan                 = var.plan_compute
  facility             = var.facility
  ssh_private_key_path = var.ssh_private_key_path
  project_id           = var.project_id
  cf_zone_id           = var.cf_zone_id
  bastion_ip           = module.bastion.nginx_ip
  node_type            = "worker"
  depends              = [module.openshift_masters.node_ip]
}

