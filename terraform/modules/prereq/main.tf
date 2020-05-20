variable "cluster_name" {}
variable "cluster_basedomain" {}
variable "ssh_public_key_path" {}
variable "count_master" {}
variable "count_compute" {}
variable "bastion_ip" {}

resource "null_resource" "ocp_installer" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/get-ocp-installer.sh ${path.root}"
  }
}

resource "null_resource" "ocp_pullsecret" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/get-pull-secret.sh > ${path.root}/artifacts/pullsecret.json"
  }
}

data "template_file" "installer_config" {
  depends_on = [null_resource.ocp_pullsecret]
  template = "${file("${path.module}/install-config.yaml.tpl")}"
  vars = {
    cluster_name         = var.cluster_name
    cluster_basedomain   = var.cluster_basedomain
    ssh_public_key_path = var.ssh_public_key_path
    count_master         = var.count_master
    count_compute        = var.count_compute
    pullsecret_path      = "${path.root}/artifacts/pullsecret.json"
  }
}

resource "null_resource" "ocp_install_config" {
  depends_on = [data.template_file.installer_config, null_resource.ocp_installer, null_resource.ocp_pullsecret]
  provisioner "local-exec" {
    command = "cat > ${path.root}/artifacts/install/install-config.yaml <<EOL\n${data.template_file.installer_config.rendered}\nEOL"
  }
}

resource "null_resource" "ocp_install_manifests" {
  depends_on = [null_resource.ocp_install_config]
  provisioner "local-exec" {
    command = "${path.root}/artifacts/openshift-install create ignition-configs --dir ${path.root}/artifacts/install"
  }
}

output "finished" {
    depends_on = [null_resource.ocp_install_manifests]
    value      = "null"
}

//provisioner "file" {
//  source       = "${path.root}/artifacts/"
//  destination = "/usr/share/nginx"
//}


