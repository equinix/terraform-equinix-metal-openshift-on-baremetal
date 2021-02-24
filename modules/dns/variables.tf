variable "node_type" {}
variable "cluster_name" {}
variable "cluster_basedomain" {}
variable "node_ips" {
  type = list(any)
}

variable "dns_provider" {
  type        = string
  description = "Name of the DNS module to use (cloudflare, linode)"
  default     = "cloudflare"
}

variable "dns_options" {
  type        = any
  description = <<EOS
  Options specific to the dns module. Check the documentation for the dns module for details. Example: `{"api_token": "..."}`

  Cloudflare options include `email`, `api_key`, and `api_token`.
  The Cloudflare API Token can be used as an alternative to using email and api_key, which must be used together.

  Linode options include `api_token`. The Linode API Token must have read-write DNS Zone access for the domain being used.
  EOS
  default     = null
}
