variable "node_type" {}
variable "cluster_name" {}
variable "cluster_basedomain" {}
variable "node_ips" {
  type = list(any)
}

