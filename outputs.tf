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
