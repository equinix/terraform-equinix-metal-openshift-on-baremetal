output "node_ip" {
    value = packet_device.node.*.access_public_ipv4
}
