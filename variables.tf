
variable "dns_provider" {
  type        = string
  description = "Name of the DNS module to use (cloudflare, linode)"
  default     = "cloudflare"
}

variable "dns_options" {
  type        = any
  description = "Options specific to the dns module. Check the documentation for the dns module for details. Example: {\"email\":\"\", \"api_key\": \"\"}"
  default     = null
}

variable "cluster_basedomain" {
  description = "Your Cloudflare Base domain for your cluster"
}


variable "auth_token" {
  description = "Your Equinix Metal API key"
  sensitive   = true
}

variable "project_id" {
  description = "Your Equinix Metal Project ID"
}

variable "bastion_operating_system" {
  description = "Your preferred bastion operating systems (RHEL or CentOS)"
  default     = "rhel_7"
}

variable "facility" {
  description = "Your primary facility"
  default     = "da11"
}

variable "plan_controlplane" {
  description = "Plan for Control Plane Nodes"
  default     = "c3.medium.x86"
}

variable "plan_compute" {
  description = "Plan for Compute Nodes"
  default     = "c2.medium.x86"
}

variable "count_bootstrap" {
  default     = "1"
  description = "Number of Control Plane Nodes."
}

variable "count_controlplane" {
  default     = "3"
  description = "Number of Control Plane Nodes."
}

variable "count_compute" {
  default     = "2"
  description = "Number of Compute Nodes"
}

variable "cluster_name" {
  default     = "metal"
  description = "Cluster name label"
}

variable "ocp_version" {
  default     = "4.9"
  description = "OpenShift minor release version"
}

variable "ocp_version_zstream" {
  default     = "0"
  description = "OpenShift zstream version"
}

variable "ocp_cluster_manager_token" {
  description = "OpenShift Cluster Manager API Token used to generate your pullSecret (https://cloud.redhat.com/openshift/token)"
  sensitive   = true
}

variable "ocp_storage_nfs_enable" {
  description = "Enable configuration of NFS and NFS-related k8s provisioner/storageClass"
  default     = true
}
variable "ocp_storage_ocs_enable" {
  description = "Enable installation of OpenShift Container Storage via operator. This requires a minimum of 3 worker nodes"
  default     = false
}

variable "ocp_virtualization_enable" {
  description = "Enable installation of OpenShift Virtualization via operator. This requires storage provided by OCS, NFS, and/or hostPath provisioner(s)"
  default     = false
}
