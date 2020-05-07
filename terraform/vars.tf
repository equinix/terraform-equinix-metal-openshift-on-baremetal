variable "cf_email" {
  description = "Your Cloudflare email address"
}

variable "cf_api_key" {
  description = "Your Cloudflare API key"
}

variable "cf_zone_id" {
  description = "Your Cloudflare Zone"
}

variable "auth_token" {
  description = "Your Packet API key"
}

variable "project_id" {
  description = "Your Packet Project ID"
}

variable "ssh_private_key_path" {
  description = "Your SSH private key path (used locally only)"
  default     = "~/.ssh/id_rsa"
}

variable "facility" {
  description = "Your primary facility"
  default     = "ewr1"
}

variable "plan_master" {
  description = "Plan for Master Nodes"
  default     = "c1.small.x86"
}

variable "plan_compute" {
  description = "Plan for Compute Nodes"
  default     = "t1.small.x86"
}

variable "count_master" {
  default     = "3"
  description = "Number of Master Nodes."
}

variable "count_compute" {
  default = "2"
  description = "Number of Compute Nodes"
}

variable "cluster_name" {
  default = "packet-openshift"
  description = "Cluster name label"
}

