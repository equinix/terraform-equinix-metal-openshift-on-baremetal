terraform {
  required_providers {
    equinix = {
      source = "equinix/equinix"
      version = "~> 2.0"
    }
    null = {
      source = "hashicorp/null"
    }
  }
  required_version = ">= 1.0.0"
  provider_meta "equinix" {
    module_name = "equinix-metal-openshift-on-baremetal/bastion"
  }
}
