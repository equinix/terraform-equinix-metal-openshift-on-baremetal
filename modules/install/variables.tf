variable "depends" {
  type    = any
  default = null
}

variable "ssh_private_key_path" {}
variable "bastion_ip" {}
variable "count_controlplane" {}
variable "count_compute" {}
variable "operating_system" {}
variable "cluster_name" {}
variable "cluster_basedomain" {}
variable "ocp_storage_nfs_enable" {}
variable "ocp_storage_ocs_enable" {}
variable "ocp_virtualization_enable" {}
variable "bootstrap_ip" {
  type = list(any)
}
variable "controlplane_ips" {
  type = list(any)
}
variable "worker_ips" {
  type = list(any)
}

