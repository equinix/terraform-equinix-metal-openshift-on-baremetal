variable "depends" {
  type    = any
  default = null
}

variable "ssh_private_key_path" {}
variable "cluster_name" {}
variable "cluster_basedomain" {}
variable "cf_zone_id" {}
variable "ocp_version" {}
variable "ocp_version_zstream" {}
variable "nodes" {
  description = "Generic list of OpenShift node types"
  type        = list(string)
  default     = ["bootstrap", "master", "worker"]
}

provider "packet" {
    auth_token = var.auth_token
}

data "template_file" "user_data" { 
    template = file("${path.module}/templates/user_data.sh")
}

data "template_file" "nginx_lb" {
    template = file("${path.module}/templates/nginx-lb.conf.tpl")

  vars = {
    cluster_name         = var.cluster_name
    cluster_basedomain   = var.cluster_basedomain
  }

}

data "template_file" "ipxe_script" {
  depends_on = [packet_device.nginx]
  for_each   = toset(var.nodes)
  template   = file("${path.module}/templates/ipxe.tpl")

  vars = {
    node_type           = each.value
    bastion_ip          = packet_device.nginx.access_public_ipv4 
    ocp_version         = var.ocp_version
    ocp_version_zstream = var.ocp_version_zstream
  }
}

output "ipxe" {
  value = data.template_file.ipxe_script
}

resource "packet_device" "nginx" {
    hostname = "nginx.${var.cluster_name}.${var.cluster_basedomain}" 
    plan = var.plan
    facilities = [var.facility]
    operating_system = var.operating_system
    billing_cycle = var.billing_cycle
    project_id = var.project_id
    user_data = data.template_file.user_data.rendered

}

resource "null_resource" "dircheck" {

provisioner "remote-exec" {

  connection {
    private_key = "${file("${var.ssh_private_key_path}")}"
    host        = packet_device.nginx.access_public_ipv4
  }


  inline = [
    "while [ ! -d /usr/share/nginx/html ]; do sleep 2; done; ls /usr/share/nginx/html/",
    "while [ ! -f /usr/lib/systemd/system/nfs-server.service ]; do sleep 2; done; ls /usr/lib/systemd/system/nfs-server.service"
  ]
}


}

//START OF NULL FILE RESOURCE

resource "null_resource" "file_uploads" {

  depends_on = [null_resource.dircheck]

provisioner "file" {

  connection {
    private_key = "${file("${var.ssh_private_key_path}")}"
    host        = packet_device.nginx.access_public_ipv4
  }

  source       = "${path.root}/artifacts/install/bootstrap.ign"
  destination = "/usr/share/nginx/html/bootstrap.ign"
}

provisioner "file" {

  connection {
    private_key = "${file("${var.ssh_private_key_path}")}"
    host        = packet_device.nginx.access_public_ipv4
  }

  source       = "${path.root}/artifacts/install/master.ign"
  destination = "/usr/share/nginx/html/master.ign"
}

provisioner "file" {

  connection {
    private_key = "${file("${var.ssh_private_key_path}")}"
    host        = packet_device.nginx.access_public_ipv4
  }

  source       = "${path.root}/artifacts/install/worker.ign"
  destination = "/usr/share/nginx/html/worker.ign"
}

//provisioner "file" {
//
//  connection {
//    private_key = "${file("${var.ssh_private_key_path}")}"
//    host        = packet_device.nginx.access_public_ipv4
//  }
//
//  content       = data.template_file.nginx_lb.rendered
//  destination = "/usr/share/nginx/modules/nginx-lb.conf"
//}

provisioner "remote-exec" {

  connection {
    private_key = "${file("${var.ssh_private_key_path}")}"
    host        = packet_device.nginx.access_public_ipv4
  }


  inline = [
    "chmod -R 0755 /usr/share/nginx/html/",
  ]
}
}
//END OF NULL FILE RESOURCE

resource "null_resource" "ipxe_files" {

  depends_on = [null_resource.dircheck]  
  for_each  = data.template_file.ipxe_script

  provisioner "file" {

    connection {
      private_key = "${file("${var.ssh_private_key_path}")}"
      host        = packet_device.nginx.access_public_ipv4
    }

    content       = each.value.rendered
    destination = "/usr/share/nginx/html/${ each.key }.ipxe"
  }

  provisioner "remote-exec" {

    connection {
      private_key = "${file("${var.ssh_private_key_path}")}"
      host        = packet_device.nginx.access_public_ipv4
    }


    inline = [
      "chmod -R 0755 /usr/share/nginx/html/",
    ]
  }
}

resource "cloudflare_record" "dns_a_cluster_api" {
  zone_id    = var.cf_zone_id
  type       = "A"
  name       = "api.${var.cluster_name}.${var.cluster_basedomain}"
  value      = packet_device.nginx.access_public_ipv4
}

resource "cloudflare_record" "dns_a_cluster_api_int" {
  zone_id    = var.cf_zone_id
  type       = "A"
  name       = "api-int.${var.cluster_name}.${var.cluster_basedomain}"
  value      = packet_device.nginx.access_public_ipv4
}

resource "cloudflare_record" "dns_a_cluster_wildcard_https" {
  zone_id    = var.cf_zone_id
  type       = "A"
  name       = "*.apps.${var.cluster_name}.${var.cluster_basedomain}"
  value      = packet_device.nginx.access_public_ipv4
}

output "finished" {
    depends_on = [null_resource.file_uploads, null_resource.ipxe_files]
    value      = "Nginx HTTP/LB provisioning finished."
}

