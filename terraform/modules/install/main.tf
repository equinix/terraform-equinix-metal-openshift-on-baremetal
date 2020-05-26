variable "depends" {
  type    = any
  default = null
}

variable "ssh_private_key_path" {}
variable "bastion_ip" {}

resource "null_resource" "ocp_installer_wait_for_bootstrap" {

  depends_on = [var.depends]

  provisioner "local-exec" {
  command    = <<EOT
    while [ ! -f ${path.root}/artifacts/install/auth/kubeconfig ]; do sleep 2; done; 
    ${path.root}/artifacts/openshift-install --dir ${path.root}/artifacts/install wait-for bootstrap-complete;
  EOT
  }
}

resource "null_resource" "ocp_bootstrap_cleanup" {
  depends_on = [null_resource.ocp_installer_wait_for_bootstrap]
  provisioner "remote-exec" {

    connection {
      private_key = "${file("${var.ssh_private_key_path}")}"
      host        = var.bastion_ip
    }

    inline = [
      "sed -i '/server bootstrap-/d' /usr/share/nginx/modules/nginx-lb.conf",
      "systemctl restart nginx"
    ]
  }
}

resource "null_resource" "ocp_installer_wait_for_completion" {

  depends_on = [null_resource.ocp_installer_wait_for_bootstrap, null_resource.ocp_bootstrap_cleanup ]

  provisioner "local-exec" {
  command    = <<EOT
    while [ ! -f ${path.root}/artifacts/install/auth/kubeconfig ]; do sleep 2; done;
    ${path.root}/artifacts/openshift-install --dir ${path.root}/artifacts/install wait-for install-complete;
  EOT
  }
}

//resource "null_resource" "ocp_approve_pending_csrs" {
//
//  depends_on = [ null_resource.ocp_installer_wait_for_completion ]
//
//  provisioner "local-exec" {
//  command    = <<EOT
//    source ${path.root}/artifacts/install/auth/kubeconfig;
//    while [ ! -f ${path.root}/artifacts/install/auth/kubeconfig ]; do sleep 2; done;
//    ${path.root}/artifacts/openshift-install --dir ${path.root}/artifacts/install wait-for install-complete;
//  EOT
//  }
//}

output "finished" {
    depends_on = [null_resource.ocp_install_wait_for_bootstrap, null_resource.ocp_bootstrap_cleanup, null_resource.ocp_installer_wait_for_completion ]
    value      = "OpenShift install wait and cleanup finished"
}

