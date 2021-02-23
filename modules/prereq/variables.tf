variable "cluster_name" {}
variable "cluster_basedomain" {}
variable "ocp_version" {}
variable "ssh_public_key_path" {}
variable "ssh_private_key_path" {}
variable "count_master" {}
variable "count_compute" {}
variable "bastion_ip" {}
variable "ocp_api_token" {}
variable "depends" {
  type    = any
  default = null
}
