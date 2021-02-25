// Modules can not be used with count with nested providers. So we move the
// provider definitions to this layer and assume that an invalid token for the
// unused provider will not prevent the needed provider from succeeding.


provider "cloudflare" {
  api_token = try(var.dns_options.api_token, "")
  api_key   = try(var.dns_options.api_key, "")
  email     = try(var.dns_options.email, "")
}

provider "linode" {
  token = try(var.dns_options.api_token, "")
}
module "cloudflare" {
  count  = (var.dns_provider == "cloudflare") ? 1 : 0
  source = "./modules/cloudflare"

  node_type          = var.node_type
  cluster_name       = var.cluster_name
  cluster_basedomain = var.cluster_basedomain
  node_ips           = var.node_ips
}


module "linode" {
  count  = (var.dns_provider == "linode") ? 1 : 0
  source = "./modules/linode"

  node_type          = var.node_type
  cluster_name       = var.cluster_name
  cluster_basedomain = var.cluster_basedomain
  node_ips           = var.node_ips
}

