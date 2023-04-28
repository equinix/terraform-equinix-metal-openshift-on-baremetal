variable "plan" {}
variable "node_count" {}
variable "metro" {}
variable "cluster_name" {}
variable "cluster_basedomain" {}
variable "ssh_private_key_path" {}
variable "project_id" {}
variable "bastion_ip" {}
variable "node_type" {}
variable "depends" {
  type    = any
  default = null
}
