variable "cluster_subnet" { default = "192.168.100.0/22" }
variable "metal_metro" { default = "da" }
variable "create_vrf" { default = true }
variable "project_id" {}

variable "create_vlan" {
  type        = bool
  default     = true
  description = "Whether to create a new VLAN for this project."
}
variable "metal_vlan_id" {
  type        = number
  default     = null
  description = "ID of the VLAN you wish to use."
}

variable "metal_vlan_description" {
  type        = string
  default     = "openshift-demo"
  description = "Description to add to created VLAN."
}


variable "vrf_id" {
  type        = string
  default     = null
  description = "ID of the VRF you wish to use."
}