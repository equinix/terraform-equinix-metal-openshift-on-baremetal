terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    external = {
      source = "hashicorp/external"
    }
    metal = {
      source  = "equinix/metal"
      version = "1.1.0"
    }
    null = {
      source = "hashicorp/null"
    }
  }
  required_version = ">= 0.14"
}
