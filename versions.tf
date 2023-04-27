terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.6.0" # pinned to prevent required credentials in newer versions
    }
    external = {
      source = "hashicorp/external"
    }

    linode = {
      source = "linode/linode"
    }

    equinix = {
      source  = "equinix/equinix"
      version = "1.11.1"
    }
    null = {
      source = "hashicorp/null"
    }
  }
  required_version = ">= 0.14"
}
