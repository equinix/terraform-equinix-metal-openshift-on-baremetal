terraform {
  required_providers {
    equinix = {
      source = "equinix/equinix"
    }
    null = {
      source = "hashicorp/null"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 0.14"
}
