variable "depends" {
  type    = any
  default = null
}

variable "ssh_private_key_path" {}
variable "bastion_ip" {}
variable "count_master" {}
variable "count_compute" {}
variable "cluster_name" {}
variable "cluster_basedomain" {}

variable "bootstrap_ip" {
  type = list
}
variable "master_ips" {
  type = list
}
variable "worker_ips" {
  type = list
}


locals {
  expanded_masters = <<-EOT
        %{ for i in range(length(var.master_ips)) ~} 
        server ${element(var.master_ips, i)}:6443; 
        %{ endfor ~}
  EOT
  expanded_mcs = <<-EOT
        %{ for i in range(length(var.master_ips)) ~} 
        server ${element(var.master_ips, i)}:22623; 
        %{ endfor ~}
  EOT
  expanded_compute_https = <<-EOT
        %{ for i in range(length(var.worker_ips)) ~}
        server ${element(var.worker_ips, i)}:443; 
        %{ endfor ~}
  EOT
  expanded_compute_http = <<-EOT
        %{ for i in range(length(var.worker_ips)) ~}
        server ${element(var.worker_ips, i)}:80;
        %{ endfor ~}
  EOT

}

data "template_file" "nginx_lb" {
    depends_on = [ var.depends ]
    template   = file("${path.module}/templates/nginx-lb.conf.tpl")

  vars = {
    expanded_masters       = local.expanded_masters
    expanded_compute_http  = local.expanded_compute_http
    expanded_compute_https = local.expanded_compute_https
    expanded_mcs           = local.expanded_mcs
    bootstrap_ip           = element(var.bootstrap_ip, 0)
  }

}

resource "null_resource" "reconfig_lb" {

  depends_on = [ var.depends ]

  provisioner "file" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = var.bastion_ip
    }

    content       = data.template_file.nginx_lb.rendered
    destination = "/usr/share/nginx/modules/nginx-lb.conf"
  }

  provisioner "remote-exec" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = var.bastion_ip
    }


    inline = [
      "systemctl restart nginx"
    ]
  }

}

resource "null_resource" "ocp_installer_wait_for_bootstrap" {

  depends_on = [var.depends]

  provisioner "local-exec" {
  command    = <<EOT
    while [ ! -f ${path.root}/artifacts/install/auth/kubeconfig ]; do sleep 2; done; 
    ${path.root}/artifacts/openshift-install --dir ${path.root}/artifacts/install wait-for bootstrap-complete;
  EOT
  }
}

locals {
  expanded_masters_nfs = <<-EOT
    %{ for i in range(length(var.master_ips)) ~}
/mnt/nfs/ocp  ${element(var.master_ips, i)}(rw,no_root_squash)
    %{ endfor ~}
  EOT
  expanded_compute_nfs = <<-EOT
    %{ for i in range(length(var.worker_ips)) ~}
/mnt/nfs/ocp  ${element(var.worker_ips, i)}(rw,no_root_squash)
    %{ endfor ~}
  EOT
}

data "template_file" "nfs_exports" {
    template = <<-EOT
    ${local.expanded_masters_nfs}
    ${local.expanded_compute_nfs}
    EOT
}

resource "null_resource" "reconfig_nfs_exports" {

  depends_on = [var.depends]

  provisioner "file" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = var.bastion_ip
    }

    content       = data.template_file.nfs_exports.rendered
    destination = "/etc/exports"
  }

  provisioner "remote-exec" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = var.bastion_ip
    }

    inline = [
      "systemctl restart nfs-server",
      "exportfs -s"
    ]
  }

}

resource "null_resource" "ocp_bootstrap_cleanup" {
  depends_on = [null_resource.ocp_installer_wait_for_bootstrap]
  provisioner "remote-exec" {

    connection {
      private_key = file(var.ssh_private_key_path)
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

resource "null_resource" "ocp_approve_pending_csrs" {

  depends_on = [ null_resource.ocp_installer_wait_for_bootstrap, null_resource.ocp_bootstrap_cleanup ]

  provisioner "local-exec" {
  command    = <<EOT
    while [ ! -f ${path.root}/artifacts/install/auth/kubeconfig ]; do sleep 2; done;
    sleep 300;
    export KUBECONFIG="${path.root}/artifacts/install/auth/kubeconfig";
    export oc=${path.root}/artifacts/oc
    $oc get csr -oname | xargs $oc adm certificate approve;
    sleep 180;
    $oc get csr -oname | xargs $oc adm certificate approve;
  EOT
  }
}

resource "null_resource" "ocp_nfs_provisioner" {

  depends_on = [ null_resource.ocp_installer_wait_for_completion ]

  provisioner "local-exec" {
  command    = "${path.module}/templates/nfs-provisioner.sh ${abspath(path.root)} ${var.bastion_ip}"
  
  }
}


output "finished" {
    depends_on = [null_resource.ocp_install_wait_for_bootstrap, null_resource.ocp_bootstrap_cleanup, null_resource.ocp_installer_wait_for_completion ]
    value      = "OpenShift install wait and cleanup finished"
}

