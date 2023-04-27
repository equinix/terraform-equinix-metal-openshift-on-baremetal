locals {
  arch           = "x86_64"
  coreos_baseurl = "https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos"
  coreos_url     = "${local.coreos_baseurl}/${var.ocp_version}/${var.ocp_version}.${var.ocp_version_zstream}"
  coreos_filenm  = "rhcos-${var.ocp_version}.${var.ocp_version_zstream}-${local.arch}"
  coreos_img     = "${local.coreos_filenm}-live-rootfs.${local.arch}.img"
  coreos_kernel  = "${local.coreos_filenm}-live-kernel-${local.arch}"
  coreos_initrd  = "${local.coreos_filenm}-live-initramfs.${local.arch}.img"

}

resource "equinix_metal_device" "lb" {
  hostname         = "lb-0.${var.cluster_name}.${var.cluster_basedomain}"
  plan             = var.plan
  metro            = var.metro
  operating_system = var.operating_system
  billing_cycle    = var.billing_cycle
  project_id       = var.project_id
  user_data        = file("${path.module}/assets/user_data_${var.operating_system}.sh")
}

resource "null_resource" "dircheck" {

  provisioner "remote-exec" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = equinix_metal_device.lb.access_public_ipv4
    }


    inline = [
      "while [ ! -d /usr/share/nginx/html ]; do sleep 2; done; ls /usr/share/nginx/html/",
      "while [ ! -f /usr/lib/systemd/system/nfs-server.service ]; do sleep 2; done; ls /usr/lib/systemd/system/nfs-server.service"
    ]
  }
}

resource "null_resource" "ocp_install_ignition" {

  depends_on = [null_resource.dircheck]


  provisioner "remote-exec" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = equinix_metal_device.lb.access_public_ipv4
    }


    inline = [
      "curl -fsSL -o /usr/share/nginx/html/${local.coreos_img} ${local.coreos_url}/${local.coreos_img}",
      "curl -fsSL -o /usr/share/nginx/html/${local.coreos_kernel} ${local.coreos_url}/${local.coreos_kernel}",
      "curl -fsSL -o /usr/share/nginx/html/${local.coreos_initrd} ${local.coreos_url}/${local.coreos_initrd}",
      "chmod -R 0755 /usr/share/nginx/html/"
    ]
  }
}

resource "null_resource" "ipxe_files" {

  depends_on = [equinix_metal_device.lb, null_resource.dircheck]
  for_each   = toset(var.nodes)

  provisioner "file" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = equinix_metal_device.lb.access_public_ipv4
    }

    content = templatefile("${path.module}/assets/ipxe.tpl", {
      node_type           = each.value
      bastion_ip          = equinix_metal_device.lb.access_public_ipv4
      ocp_version         = var.ocp_version
      ocp_version_zstream = var.ocp_version_zstream
    })
    destination = "/usr/share/nginx/html/${each.key}.ipxe"
  }

  provisioner "remote-exec" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = equinix_metal_device.lb.access_public_ipv4
    }


    inline = [
      "chmod -R 0755 /usr/share/nginx/html/",
    ]
  }
}

resource "null_resource" "ignition_append_files" {

  depends_on = [equinix_metal_device.lb, null_resource.dircheck]
  for_each   = toset(var.nodes)

  provisioner "file" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = equinix_metal_device.lb.access_public_ipv4
    }

    content = templatefile("${path.module}/assets/ignition-append.json.tpl", {
      node_type          = each.value
      bastion_ip         = equinix_metal_device.lb.access_public_ipv4
      cluster_name       = var.cluster_name
      cluster_basedomain = var.cluster_basedomain
    })
    destination = "/usr/share/nginx/html/${each.key}-append.ign"
  }

  provisioner "remote-exec" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = equinix_metal_device.lb.access_public_ipv4
    }


    inline = [
      "chmod -R 0755 /usr/share/nginx/html/",
    ]
  }
}
