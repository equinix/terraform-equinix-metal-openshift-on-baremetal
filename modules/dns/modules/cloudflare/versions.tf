terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4.35"
    }
  }
  required_version = ">= 0.13"
}
