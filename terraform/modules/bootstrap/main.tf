variable "plan" {}
variable "node_count" {}
variable "facility" {}
variable "cluster_name" {}
variable "cluster_basedomain" {}
variable "ssh_private_key_path" {}
variable "project_id" {}
variable "cf_zone_id" {}
variable "bastion_ip" {}

resource "packet_device" "bootstrap" {
  hostname           = "${format("bootstrap-%01d.${var.cluster_name}.${var.cluster_basedomain}", count.index)}"
  operating_system   = "custom_ipxe"
  ipxe_script_url    = "http://shifti.us/ipxe/?ep=${var.bastion_ip}&node=bootstrap"
  plan               = "${var.plan}"
  facilities         = ["${var.facility}"]
  count              = "${var.node_count}"

  billing_cycle    = "hourly"
  project_id       = "${var.project_id}"

  //user_data        = "${file("${path.root}/artifacts/bootstrap.ign")}"
}

resource "cloudflare_record" "dns_a_bootstrap" {
  zone_id    = "${var.cf_zone_id}"
  type       = "A"
  name       = "bootstrap-${count.index}.${var.cluster_name}.${var.cluster_basedomain}"
  value      = "${packet_device.bootstrap[count.index].access_public_ipv4}"
  count      = "${var.node_count}"
}

data "template_file" "nginx_lb" {
    template = file("${path.module}/templates/nginx-lb.conf.tpl")

  vars = {
    cluster_name         = var.cluster_name
    cluster_basedomain   = var.cluster_basedomain
  }

}

resource "null_resource" "dircheck" {

  provisioner "remote-exec" {

    connection {
      private_key = "${file("${var.ssh_private_key_path}")}"
      host        = var.bastion_ip
    } 


    inline = [
      "while [ ! -d /usr/share/nginx/html ]; do sleep 2; done; ls /usr/share/nginx/html/"
    ]
  }
}


resource "null_resource" "reconfig_lb" {

  depends_on = [ null_resource.dircheck ]

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
