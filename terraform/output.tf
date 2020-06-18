resource "null_resource" "get_kubeconfig" {

  depends_on = [module.prepare_openshift.finished]

  provisioner "local-exec" {
    command = "mkdir -p ${path.root}/auth; scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.ssh_private_key_path} root@${module.bastion.lb_ip}:/tmp/artifacts/install/auth/* ${path.root}/auth/"
  }
}

data "external" "kubeadmin_password" {
  
  depends_on = [null_resource.get_kubeconfig]

  program    = ["/bin/bash", "-c", "[ -f \"${path.root}/auth/kubeadmin-password\" ] && echo \"{\\\"password\\\":\\\"$(cat ${path.root}/auth/kubeadmin-password)\\\"}\""]
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
