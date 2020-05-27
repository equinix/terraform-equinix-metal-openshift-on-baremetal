data "external" "kubeadmin_password" {
  depends_on = [module.openshift_install.finished]
  program    = ["/bin/bash", "-c", "[ -f \"artifacts/install/auth/kubeadmin-password\" ] && echo \"{\\\"password\\\":\\\"$(cat artifacts/install/auth/kubeadmin-password)\\\"}\""]
}

output "Information" {
  depends_on = [module.openshift_install.finished]
  value      = <<EOT


  OpenShift cluster deployed.
  Access the OpenShift Web Console at: https://console-openshift-console.apps.${var.cluster_name}.${var.cluster_basedomain}

  Username: kubeadmin
  Password: ${data.external.kubeadmin_password.result.password}

  To use the CLI:
    export KUBECONFIG="${abspath(path.root)}/artifacts/install/auth/kubeconfig"
  
  Review your nodes:
    oc get nodes

  EOT
}
