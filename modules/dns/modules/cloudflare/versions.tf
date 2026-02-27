terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
  required_version = ">= 0.13"
}
