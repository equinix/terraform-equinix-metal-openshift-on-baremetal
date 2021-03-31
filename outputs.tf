output "console" {
  description = "OpenShift cluster console"
  value       = "https://console-openshift-console.apps.${var.cluster_name}.${var.cluster_basedomain}"
}

output "username" {
  description = "OpenShift cluster console username"
  value       = "kubeadm"
}

output "password" {
  description = "OpenShift cluster console password"
  value       = data.external.kubeadmin_password.result.password
  sensitive   = true
}

output "kubeconfig" {
  description = "Local copy of the KUBECONFIG file"
  value       = "${abspath(path.root)}/auth/kubeconfig"
}

output "bastion_kubeconfig" {
  description = "Bastion copy of the KUBECONFIG file"
  value       = "/tmp/artifacts/install/auth/kubeconfig"
}

output "bastion_ip" {
  description = "Bastion IP Address"
  value       = module.bastion.lb_ip
}

output "openshift_bootstrap_ip" {
  description = "Bootstrap IP Address"
  value       = module.openshift_bootstrap.node_ip
}

output "ssh_private_key_file" {
  description = "Path to the private SSH key with root access on each node"
  value       = module.sshkey.ssh_private_key_file
}

output "ssh_public_key" {
  description = "Public SSH key of the ssh_private_key_file"
  value       = module.sshkey.ssh_public_key
}

output "openshift_controlplane_ips" {
  description = "Controlplane IP Address"
  value       = module.openshift_controlplane.*.node_ip
}

output "openshift_worker_ips" {
  description = "Worker IP Address"
  value       = module.openshift_workers.*.node_ip
}

output "Information" {
  depends_on = [module.openshift_install.finished, data.external.kubeadmin_password]
  value      = <<EOT


  OpenShift cluster deployed.
  Access the OpenShift Web Console at: https://console-openshift-console.apps.${var.cluster_name}.${var.cluster_basedomain}

  Username: kubeadmin
  Password: ${data.external.kubeadmin_password.result.password}

  To use the CLI (on bastion):
    export KUBECONFIG="/tmp/artifacts/install/auth/kubeconfig"
  
  To use the CLI (locally):
    export KUBECONFIG="${abspath(path.root)}/auth/kubeconfig"

  Review your nodes:
    oc get nodes

  EOT
}
