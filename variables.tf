
variable "dns_provider" {
  type        = string
  description = <<EOS
    Name of the DNS module to use (cloudflare, aws, linode)

    Choose the provider where cluster_basedomain's DNS is hosted.
    See the provider documentation for details on how to configure the provider. Add new modules to modules/dns.
    This module relies on external configuration, such as environment variables or provider specific configuration profiles, to configure the provider.

    Examples:

    export LINODE_TOKEN="..."
    export CLOUDFLARE_API_TOKEN="..."
    export AWS_ACCESS_KEY_ID="..."
    export AWS_SECRET_ACCESS_KEY="..."
    export AWS_REGION="us-east-1"
  EOS
  default     = "cloudflare"
}

variable "cluster_basedomain" {
  description = "Your DNS Base domain for your cluster. This is the zone in your DNS provider. i.e. worker-1.{cluster_name}.{cluster_basedomain}"
}

variable "metal_auth_token" {
  description = "Your Equinix Metal API key"
  sensitive   = true
}

variable "metal_project_id" {
  description = "Your Equinix Metal Project ID"
}

variable "bastion_operating_system" {
  description = "Your preferred bastion operating systems (RHEL or CentOS)"
  default     = "rhel_7"
}

variable "metal_metro" {
  description = "Your primary metro"
  default     = "da"
}

variable "plan_bastion" {
  description = "Plan for Bastion"
  default     = "c3.small.x86"
}
variable "plan_controlplane" {
  description = "Plan for Control Plane Nodes"
  default     = "c3.small.x86"
}

variable "plan_compute" {
  description = "Plan for Compute Nodes"
  default     = "c3.small.x86"
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
  description = "Cluster name label. cluster_name will be suffixed for all DNS names. i.e. worker-1.{cluster_name}.{cluster_basedomain}"
}

variable "ocp_version" {
  default     = "4.12"
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
