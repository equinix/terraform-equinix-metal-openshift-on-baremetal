terraform {
  required_providers {
    metal = {
      source = "equinix/metal"
    }
    null = {
      source = "hashicorp/null"
    }
  }
  required_version = ">= 0.14"
}
