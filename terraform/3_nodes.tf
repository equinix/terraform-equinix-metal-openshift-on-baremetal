module "openshift_bootstrap" {
  source = "./modules/node"

  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  node_count           = var.count_bootstrap
  plan                 = var.plan_master
  facility             = var.facility
  ssh_private_key_path = var.ssh_private_key_path
  project_id           = var.project_id
  cf_zone_id           = var.cf_zone_id
  bastion_ip           = module.bastion.lb_ip
  node_type            = "bootstrap"
  depends              = [module.prepare_openshift.finished]
}

module "dns_bootstrap" {
  source = "./modules/dns"

  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  cf_zone_id           = var.cf_zone_id
  node_type            = "bootstrap"
  node_ips             = module.openshift_bootstrap.node_ip
}

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
  bastion_ip           = module.bastion.lb_ip
  node_type            = "master"
  depends              = [module.prepare_openshift.finished]
}

module "dns_masters" {
  source = "./modules/dns"

  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  cf_zone_id           = var.cf_zone_id
  node_type            = "master"
  node_ips             = module.openshift_masters.node_ip
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
  bastion_ip           = module.bastion.lb_ip
  node_type            = "worker"
  depends              = [module.prepare_openshift.finished]
}

module "dns_workers" {
  source = "./modules/dns"

  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  cf_zone_id           = var.cf_zone_id
  node_type            = "worker"
  node_ips             = module.openshift_workers.node_ip
}