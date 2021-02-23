output "lb_ip" {
  value = metal_device.lb.access_public_ipv4
}

output "finished" {
  depends_on = [null_resource.file_uploads, null_resource.ipxe_files]
  value      = "Loadbalancer provisioning finished."
}

