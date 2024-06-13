variable "node_type" {}
variable "cluster_name" {}
variable "cluster_basedomain" {}
variable "node_ips" {
  type = list(any)
}

variable "dns_provider" {
  type        = string
  description = <<EOS
    Name of the DNS module to use (cloudflare, aws, linode)

    Choose the provider where cluster_basedomain's DNS is hosted.
    See the provider documentation for details on how to configure the provider.
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
