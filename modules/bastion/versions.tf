terraform {
  required_providers {
    equinix = {
      source = "equinix/equinix"
    }
    null = {
      source = "hashicorp/null"
    }
  }
  required_version = ">= 0.14"
}
