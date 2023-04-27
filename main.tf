provider "equinix" {
  auth_token = var.auth_token
}

module "sshkey" {
  source = "./modules/sshkey"

  cluster_name = var.cluster_name
}

module "bastion" {
  source     = "./modules/bastion"
  depends_on = [module.sshkey]

  project_id           = var.project_id
  facility             = var.facility
  plan                 = var.plan_bastion
  operating_system     = var.bastion_operating_system
  ssh_private_key_path = module.sshkey.ssh_private_key_file
  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  ocp_version          = var.ocp_version
  ocp_version_zstream  = var.ocp_version_zstream
  //depends              = [module.prepare_openshift.finished]
}

module "dns_lb" {
  source = "./modules/dns"

  dns_provider = var.dns_provider
  dns_options  = var.dns_options

  cluster_name       = var.cluster_name
  cluster_basedomain = var.cluster_basedomain
  node_type          = "lb"
  node_ips           = tolist([module.bastion.lb_ip])
}


module "prepare_openshift" {
  source = "./modules/prereq"

  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  ocp_version          = var.ocp_version
  count_controlplane   = var.count_controlplane
  count_compute        = var.count_compute
  ssh_public_key       = module.sshkey.ssh_public_key
  ssh_private_key_path = module.sshkey.ssh_private_key_file
  bastion_ip           = module.bastion.lb_ip
  ocp_api_token        = var.ocp_cluster_manager_token
  depends              = [module.bastion.finished]
}

module "openshift_bootstrap" {
  source     = "./modules/node"
  depends_on = [module.sshkey]

  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  node_count           = var.count_bootstrap
  plan                 = var.plan_controlplane
  facility             = var.facility
  ssh_private_key_path = module.sshkey.ssh_private_key_file
  project_id           = var.project_id
  bastion_ip           = module.bastion.lb_ip
  node_type            = "bootstrap"
  depends              = [module.prepare_openshift.finished]
}

module "dns_bootstrap" {
  source = "./modules/dns"

  dns_provider = var.dns_provider
  dns_options  = var.dns_options

  cluster_name       = var.cluster_name
  cluster_basedomain = var.cluster_basedomain
  node_type          = "bootstrap"
  node_ips           = module.openshift_bootstrap.node_ip
}

module "openshift_controlplane" {
  source     = "./modules/node"
  depends_on = [module.sshkey]

  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  node_count           = var.count_controlplane
  plan                 = var.plan_controlplane
  facility             = var.facility
  ssh_private_key_path = module.sshkey.ssh_private_key_file
  project_id           = var.project_id
  bastion_ip           = module.bastion.lb_ip
  node_type            = "master"
  depends              = [module.prepare_openshift.finished]
}

module "dns_controlplane" {
  source = "./modules/dns"

  dns_provider = var.dns_provider
  dns_options  = var.dns_options

  cluster_name       = var.cluster_name
  cluster_basedomain = var.cluster_basedomain
  node_type          = "master"
  node_ips           = module.openshift_controlplane.node_ip
}

module "openshift_workers" {
  source     = "./modules/node"
  depends_on = [module.sshkey]

  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  node_count           = var.count_compute
  plan                 = var.plan_compute
  facility             = var.facility
  ssh_private_key_path = module.sshkey.ssh_private_key_file
  project_id           = var.project_id
  bastion_ip           = module.bastion.lb_ip
  node_type            = "worker"
  depends              = [module.prepare_openshift.finished]
}

module "dns_workers" {
  source = "./modules/dns"

  dns_provider = var.dns_provider
  dns_options  = var.dns_options

  cluster_name       = var.cluster_name
  cluster_basedomain = var.cluster_basedomain
  node_type          = "worker"
  node_ips           = module.openshift_workers.node_ip
}

module "openshift_install" {
  source = "./modules/install"

  ssh_private_key_path = module.sshkey.ssh_private_key_file
  operating_system     = var.bastion_operating_system
  bastion_ip           = module.bastion.lb_ip
  count_controlplane   = var.count_controlplane
  count_compute        = var.count_compute
  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  bootstrap_ip         = module.openshift_bootstrap.node_ip
  controlplane_ips     = module.openshift_controlplane.node_ip
  worker_ips           = module.openshift_workers.node_ip
  depends              = [module.openshift_controlplane.node_ip, module.openshift_workers.node_ip]

  ocp_storage_nfs_enable    = var.ocp_storage_nfs_enable
  ocp_storage_ocs_enable    = var.ocp_storage_ocs_enable
  ocp_virtualization_enable = var.ocp_virtualization_enable
}

resource "null_resource" "get_kubeconfig" {
  depends_on = [module.prepare_openshift.finished]

  provisioner "local-exec" {
    command = "mkdir -p ${path.root}/auth; scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${module.sshkey.ssh_private_key_file} root@${module.bastion.lb_ip}:/tmp/artifacts/install/auth/* ${path.root}/auth/"
  }
}

data "external" "kubeadmin_password" {
  depends_on = [null_resource.get_kubeconfig]

  program = ["/bin/bash", "-c", "[ -f \"${path.root}/auth/kubeadmin-password\" ] && echo \"{\\\"password\\\":\\\"$(cat ${path.root}/auth/kubeadmin-password)\\\"}\""]
}
