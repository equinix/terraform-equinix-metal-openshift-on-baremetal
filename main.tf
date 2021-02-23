provider "metal" {
  auth_token = var.auth_token
}

provider "cloudflare" {
  email   = var.cf_email
  api_key = var.cf_api_key
}

module "bastion" {

  source               = "./modules/bastion"
  auth_token           = var.auth_token
  project_id           = var.project_id
  facility             = var.facility
  plan                 = var.plan_master
  operating_system     = var.bastion_operating_system
  ssh_private_key_path = var.ssh_private_key_path
  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  cf_zone_id           = var.cf_zone_id
  ocp_version          = var.ocp_version
  ocp_version_zstream  = var.ocp_version_zstream
  //depends              = [module.prepare_openshift.finished]
}

module "dns_lb" {
  source = "./modules/dns"

  cluster_name       = var.cluster_name
  cluster_basedomain = var.cluster_basedomain
  cf_zone_id         = var.cf_zone_id
  node_type          = "lb"
  node_ips           = tolist([module.bastion.lb_ip])
}


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

  cluster_name       = var.cluster_name
  cluster_basedomain = var.cluster_basedomain
  cf_zone_id         = var.cf_zone_id
  node_type          = "bootstrap"
  node_ips           = module.openshift_bootstrap.node_ip
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

  cluster_name       = var.cluster_name
  cluster_basedomain = var.cluster_basedomain
  cf_zone_id         = var.cf_zone_id
  node_type          = "master"
  node_ips           = module.openshift_masters.node_ip
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

  cluster_name       = var.cluster_name
  cluster_basedomain = var.cluster_basedomain
  cf_zone_id         = var.cf_zone_id
  node_type          = "worker"
  node_ips           = module.openshift_workers.node_ip
}

module "openshift_install" {
  source = "./modules/install"

  ssh_private_key_path = var.ssh_private_key_path
  operating_system     = var.bastion_operating_system
  bastion_ip           = module.bastion.lb_ip
  count_master         = var.count_master
  count_compute        = var.count_compute
  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  bootstrap_ip         = module.openshift_bootstrap.node_ip
  master_ips           = module.openshift_masters.node_ip
  worker_ips           = module.openshift_workers.node_ip
  depends              = [module.openshift_masters.node_ip, module.openshift_workers.node_ip]

  ocp_storage_nfs_enable    = var.ocp_storage_nfs_enable
  ocp_storage_ocs_enable    = var.ocp_storage_ocs_enable
  ocp_virtualization_enable = var.ocp_virtualization_enable
}

resource "null_resource" "get_kubeconfig" {

  depends_on = [module.prepare_openshift.finished]

  provisioner "local-exec" {
    command = "mkdir -p ${path.root}/auth; scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.ssh_private_key_path} root@${module.bastion.lb_ip}:/tmp/artifacts/install/auth/* ${path.root}/auth/"
  }
}

data "external" "kubeadmin_password" {

  depends_on = [null_resource.get_kubeconfig]

  program = ["/bin/bash", "-c", "[ -f \"${path.root}/auth/kubeadmin-password\" ] && echo \"{\\\"password\\\":\\\"$(cat ${path.root}/auth/kubeadmin-password)\\\"}\""]
}
