output "vrf_id" {
value = local.vrf_id
}

output "vlan_id" {
value = local.vlan_id
}

output "reserved_ip_block_id" {
value = equinix_metal_reserved_ip_block.openshift.id
}
