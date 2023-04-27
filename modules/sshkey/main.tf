resource "random_string" "cluster_suffix" {
  length  = 5
  special = false
  upper   = false
}

locals {
  cluster_name = format("%s-%s", var.cluster_name, random_string.cluster_suffix.result)

  ssh_key_name = format("id_rsa_%s", local.cluster_name)
}

resource "tls_private_key" "ssh_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "equinix_metal_ssh_key" "ssh_pub_key" {
  name       = local.cluster_name
  public_key = chomp(tls_private_key.ssh_key_pair.public_key_openssh)
}

resource "local_file" "cluster_private_key_pem" {
  content         = chomp(tls_private_key.ssh_key_pair.private_key_pem)
  filename        = pathexpand(format("~/.ssh/%s", local.ssh_key_name))
  file_permission = "0600"
}
