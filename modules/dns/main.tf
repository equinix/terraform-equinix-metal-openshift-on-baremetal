// Modules can not be used with count with nested providers. So we move the
// provider definitions to this layer and assume that an invalid token for the
// unused provider will not prevent the needed provider from succeeding.

# provider "cloudflare" {
#  must use environment CLOUDFLARE_API_TOKEN
#  see https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs
#}

# provider "linode" {
#  must use environment -- LINODE_TOKEN
# }

provider "aws" {
# AWS credentials are optional for this module. Skip AWS settings that require credentials.
# see https://registry.terraform.io/providers/-/aws/latest/docs#environment-variables
  skip_credentials_validation = (var.dns_provider == "aws" ? false : true)
  skip_metadata_api_check = (var.dns_provider == "aws" ? false : true) # AWS_EC2_METADATA_DISABLED
  skip_region_validation = (var.dns_provider == "aws" ? false : true) # AWS_REGION
  skip_requesting_account_id = (var.dns_provider == "aws" ? false : true)

  access_key = (var.dns_provider == "aws" ? null : "none") # use local profile config or environment AWS_ACCESS_KEY_ID
  secret_key = (var.dns_provider == "aws" ? null : "none") # use local profile config or environment AWS_SECRET_ACCESS_KEY
  region = "us-east-1"
}

module "aws" {
  count  = (var.dns_provider == "aws") ? 1 : 0
  source = "./modules/aws"

  node_type          = var.node_type
  cluster_name       = var.cluster_name
  cluster_basedomain = var.cluster_basedomain
  node_ips           = var.node_ips
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

