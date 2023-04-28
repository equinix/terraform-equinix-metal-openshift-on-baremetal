resource "null_resource" "ocp_installer" {

  depends_on = [var.depends]

  provisioner "file" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = var.bastion_ip
    }

    source      = "${path.module}/assets/get-ocp-installer.sh"
    destination = "/tmp/get-ocp-installer.sh"
  }

  provisioner "remote-exec" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = var.bastion_ip
    }


    inline = [
      "chmod +x /tmp/get-ocp-installer.sh",
      "/tmp/get-ocp-installer.sh /tmp ${var.ocp_version}"
    ]
  }
}

resource "null_resource" "ocp_pullsecret" {
  depends_on = [null_resource.ocp_installer]

  provisioner "file" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = var.bastion_ip
    }

    source      = "${path.module}/assets/get-pull-secret.sh"
    destination = "/tmp/get-pull-secret.sh"
  }

  provisioner "remote-exec" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = var.bastion_ip
    }

    inline = [
      "chmod +x /tmp/get-pull-secret.sh",
      "/tmp/get-pull-secret.sh ${var.ocp_api_token} > /tmp/artifacts/pullsecret.json"
    ]
  }
}

resource "null_resource" "ocp_install_config" {
  depends_on = [null_resource.ocp_installer, null_resource.ocp_pullsecret]

  provisioner "file" {
    connection {
      private_key = file(var.ssh_private_key_path)
      host        = var.bastion_ip
    }

    content = templatefile("${path.module}/assets/install-config.yaml.tpl", {
      cluster_name       = var.cluster_name
      cluster_basedomain = var.cluster_basedomain
      ssh_public_key     = var.ssh_public_key
      count_controlplane = var.count_controlplane
      count_compute      = var.count_compute
    })
    destination = "/tmp/artifacts/install/install-config.yaml"
  }

  provisioner "remote-exec" {
    connection {
      private_key = file(var.ssh_private_key_path)
      host        = var.bastion_ip
    }

    inline = [
      "echo -e \"\npullSecret: '$(cat /tmp/artifacts/pullsecret.json)'\" >> /tmp/artifacts/install/install-config.yaml"
    ]
  }

}

resource "null_resource" "ocp_install_manifests" {
  depends_on = [null_resource.ocp_install_config]

  provisioner "remote-exec" {
    connection {
      private_key = file(var.ssh_private_key_path)
      host        = var.bastion_ip
    }

    inline = [
      "timedatectl set-ntp no",
      "new_time=`date '+%Y-%m-%d %H:%M:%S' -d '-8 hours'`",
      "timedatectl set-time \"$${new_time}\"",
      "cp /tmp/artifacts/install/install-config.yaml /tmp/artifacts/install/install-config.yaml.backup",
      "/tmp/artifacts/openshift-install create manifests --dir /tmp/artifacts/install",
      "[[ ${var.count_compute} -ge 2 ]] && sed -i 's/mastersSchedulable: true/mastersSchedulable: false/g' /tmp/artifacts/install/manifests/cluster-scheduler-02-config.yml",
      "/tmp/artifacts/openshift-install create ignition-configs --dir /tmp/artifacts/install",
      "cp /tmp/artifacts/install/*.ign /usr/share/nginx/html/",
      "chmod -R 0755 /usr/share/nginx/html/",
      "timedatectl set-ntp yes",
      "chronyc -a 'burst 4/4'; sleep 10; chronyc -a makestep"
    ]
  }
}
