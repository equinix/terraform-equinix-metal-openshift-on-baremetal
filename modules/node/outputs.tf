output "node_ip" {
  value = equinix_metal_device.node.*.access_public_ipv4
}

output "finished" {
  value = "Provisioning node type ${var.node_type} finished."
}
