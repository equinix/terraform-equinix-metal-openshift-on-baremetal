terraform {
  required_providers {
    equinix = {
      source = "equinix/equinix"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0.0"
  provider_meta "equinix" {
    module_name = "equinix-metal-openshift-on-baremetal/node"
  }
}
