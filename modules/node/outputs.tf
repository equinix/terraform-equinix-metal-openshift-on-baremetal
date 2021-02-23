output "node_ip" {
  value = metal_device.node.*.access_public_ipv4
}
