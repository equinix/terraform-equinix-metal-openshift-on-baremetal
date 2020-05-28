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



locals {
  expanded_masters = <<-EOT
        %{ for i in range(var.count_master) ~}
        server master-${i}.${var.cluster_name}.${var.cluster_basedomain}:6443;
        %{ endfor }
  EOT
  expanded_mcs = <<-EOT
        %{ for i in range(var.count_master) ~}
        server master-${i}.${var.cluster_name}.${var.cluster_basedomain}:22623;
        %{ endfor }
  EOT
  expanded_compute = <<-EOT
        %{ for i in range(var.count_compute) ~}
        server worker-${i}.${var.cluster_name}.${var.cluster_basedomain}:443;
        %{ endfor }
  EOT
}

data "template_file" "nginx_lb" {
    depends_on = [ var.depends ]
    template   = file("${path.module}/templates/nginx-lb.conf.tpl")

  vars = {
    cluster_name         = var.cluster_name
    cluster_basedomain   = var.cluster_basedomain
    count_master         = var.count_master
    count_compute        = var.count_compute
    expanded_masters     = local.expanded_masters
    expanded_compute     = local.expanded_compute
    expanded_mcs         = local.expanded_mcs
  }

}

resource "null_resource" "reconfig_lb" {

  depends_on = [ var.depends ]

  provisioner "file" {

    connection {
      private_key = "${file("${var.ssh_private_key_path}")}"
      host        = var.bastion_ip
    }

    content       = data.template_file.nginx_lb.rendered
    destination = "/usr/share/nginx/modules/nginx-lb.conf"
  }

  provisioner "remote-exec" {

    connection {
      private_key = "${file("${var.ssh_private_key_path}")}"
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
    %{ for i in range(var.count_master) ~}
    /mnt/nfs/ocp  master-${i}.${var.cluster_name}.${var.cluster_basedomain}(rw,no_root_squash)
    %{ endfor }
  EOT
  expanded_compute_nfs = <<-EOT
    %{ for i in range(var.count_compute) ~}
    /mnt/nfs/ocp  worker-${i}.${var.cluster_name}.${var.cluster_basedomain}(rw,no_root_squash)
    %{ endfor }
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
      private_key = "${file("${var.ssh_private_key_path}")}"
      host        = var.bastion_ip
    }

    content       = data.template_file.nfs_exports.rendered
    destination = "/etc/exports"
  }

  provisioner "remote-exec" {

    connection {
      private_key = "${file("${var.ssh_private_key_path}")}"
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

resource "null_resource" "ocp_approve_pending_csrs" {

  depends_on = [ null_resource.ocp_installer_wait_for_bootstrap, null_resource.ocp_bootstrap_cleanup ]

  provisioner "local-exec" {
  command    = <<EOT
    while [ ! -f ${path.root}/artifacts/install/auth/kubeconfig ]; do sleep 2; done;
    source ${path.root}/artifacts/install/auth/kubeconfig;
    export oc=${path.root}/artifacts/oc
    while ($oc get csr | grep -q -i Pending); do echo "Still seeing Pending CSRs"; ($oc get csr -oname | xargs $oc adm certificate approve); sleep 35; done
  EOT
  }
}

resource "null_resource" "ocp_nfs_provisioner" {

  depends_on = [ null_resource.ocp_installer_wait_for_completion ]

  // Move to template/script (done already)
  // nfs-provisioner.sh /home/liveaverage/openshift-packet-deploy/terraform 139.178.88.15
  provisioner "local-exec" {
  command    = <<EOT
    source ${path.root}/artifacts/install/auth/kubeconfig;
    curl https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/rbac.yaml > ${path.root}/artifacts/install/nfsp-rbac.yaml
    curl https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/deployment.yaml > ${path.root}/artifacts/install/nfsp-deployment.yaml
    curl https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/class.yaml > ${path.root}/artifacts/install/nfsp-class.yaml
    export oc=${path.root}/artifacts/oc
    $oc create namespace openshift-nfs-storage
    $oc label namespace openshift-nfs-storage "openshift.io/cluster-monitoring=true"
    NAMESPACE=`$oc project openshift-nfs-storage -q`
    sed -i'' "s/namespace:.*/namespace: $NAMESPACE/g" ${path.root}/artifacts/install/nfsp-rbac.yaml
    sed -i'' "s/namespace:.*/namespace: $NAMESPACE/g" ${path.root}/artifacts/install/nfsp-deployment.yaml
    sed -i'' "s/10.10.10.60/${var.bastion_ip}/g" ${path.root}/artifacts/install/nfsp-deployment.yaml
    sed -i'' "s/fuseim.*/storage.io\/nfs/g" ${path.root}/artifacts/install/nfsp-deployment.yaml
    sed -i'' "s/\/var\/nfs/\/mnt\/nfs\/ocp/g" ${path.root}/artifacts/install/nfsp-deployment.yaml
    sed -i'' "s/fuseim.*/storage.io\/nfs/g" ${path.root}/artifacts/install/nfsp-deployment.yaml
    sed -i'' "s/fuseim.*/storage.io\/nfs/g" ${path.root}/artifacts/install/nfsp-class.yaml
    $oc create -f ${path.root}/artifacts/install/nfsp-rbac.yaml
    $oc adm policy add-scc-to-user hostmount-anyuid system:serviceaccount:$NAMESPACE:nfs-client-provisioner
    $oc create -f ${path.root}/artifacts/install/nfsp-class.yaml
    $oc create -f ${path.root}/artifacts/install/nfsp-deployment.yaml
  EOT
  }
}


output "finished" {
    depends_on = [null_resource.ocp_install_wait_for_bootstrap, null_resource.ocp_bootstrap_cleanup, null_resource.ocp_installer_wait_for_completion ]
    value      = "OpenShift install wait and cleanup finished"
}

