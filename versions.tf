terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.35"
    }
    external = {
      source = "hashicorp/external"
    }
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0" # Pin to a version that does not require working provider configuration
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
  required_version = "~> 1.7"
  provider_meta "equinix" {
    module_name = "equinix-metal-openshift-on-baremetal"
  }
}
