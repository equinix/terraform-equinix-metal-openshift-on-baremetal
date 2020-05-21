output "nginx_ip" {
    value = packet_device.nginx.access_public_ipv4
}
