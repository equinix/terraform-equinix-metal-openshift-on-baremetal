
module "bastion" {

  source               = "./modules/bastion"
  auth_token           = var.auth_token
  project_id           = var.project_id
  ssh_private_key_path = var.ssh_private_key_path
  depends              = [module.prepare_openshift.finished]
}

