locals {
  vlan_id                 = var.create_vlan ? element(equinix_metal_vlan.openshift[*].id, 0) : element(data.equinix_metal_vlan.openshift[*].id, 0)
  vxlan                   = var.create_vlan ? element(equinix_metal_vlan.openshift[*].vxlan, 0) : element(data.equinix_metal_vlan.openshift[*].vxlan, 0)
  vrf_id                  = var.create_vrf ? element(equinix_metal_vrf.openshift[*].id, 0) : element(data.equinix_metal_vrf.openshift[*].id, 0)
}


# This generates a random suffix to avoid VRF name
# collisions when multiple clusters are deployed to
# an existing Metal project
resource "random_string" "vrf_name_suffix" {
  length  = 5
  special = false
}


resource "equinix_metal_vlan" "openshift" {
  count       = var.create_vlan ? 1 : 0
  project_id  = var.project_id
  description = var.metal_vlan_description
  metro       = var.metal_metro
}


data "equinix_metal_vlan" "openshift" {
  count      = var.create_vlan ? 0 : 1
  project_id = var.project_id
  vxlan      = var.metal_vlan_id
}

resource "equinix_metal_vrf" "openshift" {
  count       = var.create_vrf ? 1 : 0
  description = "VRF with ASN 65000 and a pool of address space that includes 192.168.100.0/25"
  name        = "openshift-vrf-${random_string.vrf_name_suffix.result}"
  metro       = var.metal_metro
  local_asn   = "65000"
  ip_ranges   = [var.cluster_subnet]
  project_id  = var.project_id
}

data "equinix_metal_vrf" "openshift" {
  count  = var.create_vrf ? 0 : 1
  vrf_id = var.vrf_id
}

resource "equinix_metal_reserved_ip_block" "openshift" {
  description = "Reserved IP block (${var.cluster_subnet}) taken from on of the ranges in the VRF's pool of address space."
  project_id  = var.project_id
  metro       = var.metal_metro
  type        = "vrf"
  vrf_id      = local.vrf_id
  cidr        = split("/", var.cluster_subnet)[1]
  network     = cidrhost(var.cluster_subnet, 0)
}

resource "equinix_metal_gateway" "gateway" {
  project_id        = var.project_id
  vlan_id           = local.vlan_id
  ip_reservation_id = equinix_metal_reserved_ip_block.openshift.id
}