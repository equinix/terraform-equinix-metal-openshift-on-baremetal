variable "project_id" {
  description = "Equinix Metal Project ID"
  type        = string
}

variable "operating_system" {
  description = "The Operating system of the server"
  default     = "centos_8"
  type        = string
}

variable "billing_cycle" {
  description = "How the node will be billed (Not usually changed)"
  default     = "hourly"
  type        = string
}

variable "plan" {
  description = "The server type to deploy"
  default     = "c2.medium.x86"
  type        = string
}

variable "facility" {
  description = "The location of the servers"
  default     = "sjc1"
  type        = string
}

variable "depends" {
  type    = any
  default = null
}

variable "ssh_private_key_path" {}
variable "cluster_name" {}
variable "cluster_basedomain" {}
variable "ocp_version" {}
variable "ocp_version_zstream" {}
variable "nodes" {
  description = "Generic list of OpenShift node types"
  type        = list(string)
  default     = ["bootstrap", "master", "worker"]
}
