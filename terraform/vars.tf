variable "cf_email" {
  description = "Your Cloudflare email address"
}

variable "cf_api_key" {
  description = "Your Cloudflare API key"
}

variable "cf_zone_id" {
  description = "Your Cloudflare Zone"
}

variable "cluster_basedomain" {
  description = "Your Cloudflare Base domain for your cluster"
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

variable "ssh_public_key_path" {
  description = "Your SSH public key path (used for install-config.yaml)"
  default     = "~/.ssh/id_rsa.pub"
}

variable "facility" {
  description = "Your primary facility"
  default     = "dfw2"
}

variable "plan_master" {
  description = "Plan for Master Nodes"
  default     = "c2.medium.x86"
}

variable "plan_compute" {
  description = "Plan for Compute Nodes"
  default     = "c2.medium.x86"
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
  default = "jr"
  description = "Cluster name label"
}

variable "ocp_version" {
  default = "4.4"
  description = "OpenShift minor release version"
}

variable "ocp_version_zstream" {
  default = "3"
  description = "OpenShift zstream version"
}

variable "ocp_cluster_manager_token" {
  description = "OpenShift Cluster Manager API Token used to generate your pullSecret (https://cloud.redhat.com/openshift/token)"
}
