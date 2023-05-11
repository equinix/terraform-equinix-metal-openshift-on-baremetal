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
      version = "~> 1.14"
    }
    null = {
      source = "hashicorp/null"
    }
  }
  required_version = ">= 1.0.0"
  provider_meta "equinix" {
    module_name = "equinix-metal-openshift-on-baremetal"
  }
}
