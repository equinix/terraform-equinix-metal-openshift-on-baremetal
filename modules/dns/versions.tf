terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    linode = {
      source = "linode/linode"
    }
  }
  required_version = ">= 0.13"
}
