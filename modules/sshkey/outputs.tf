output "ssh_private_key_file" {
  description = "Path to the private generated SSH Key"
  value       = local_file.cluster_private_key_pem.filename
}

output "ssh_public_key" {
  description = "Contents of the generated SSH Public key"
  value       = chomp(tls_private_key.ssh_key_pair.public_key_openssh)
}
output "metal_ssh_key_id" {
  description = "Equinix Metal UUID of the public SSH Key"
  value       = equinix_metal_ssh_key.ssh_pub_key.id
}

