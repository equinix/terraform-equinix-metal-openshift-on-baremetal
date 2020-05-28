variable "plan" {}
variable "node_count" {}
variable "facility" {}
variable "cluster_name" {}
variable "cluster_basedomain" {}
variable "ssh_private_key_path" {}
variable "project_id" {}
variable "cf_zone_id" {}
variable "bastion_ip" {}
variable "node_type" {}
variable "depends" {
  type    = any
  default = null
}


resource "packet_device" "node" {
  depends_on         = [var.depends]
  hostname           = format("%s-%01d.%s.%s", var.node_type, count.index, var.cluster_name, var.cluster_basedomain)
  operating_system   = "custom_ipxe"
  ipxe_script_url    = "http://${var.bastion_ip}/${var.node_type}.ipxe"
  //ipxe_script_url    = "http://shifti.us/ipxe/?ep=${var.bastion_ip}&node=${var.node_type}"
  plan               = var.plan
  facilities         = [var.facility]
  count              = var.node_count
  billing_cycle    = "hourly"
  project_id       = var.project_id

}

resource "cloudflare_record" "dns_a_node" {
  zone_id    = var.cf_zone_id
  type       = "A"
  name       = "${var.node_type}-${count.index}.${var.cluster_name}.${var.cluster_basedomain}"
  value      = packet_device.node[count.index].access_public_ipv4
  count      = var.node_count
}

resource "cloudflare_record" "dns_a_etcd" {
  zone_id    = var.cf_zone_id
  type       = "A"
  name       = "etcd-${count.index}.${var.cluster_name}.${var.cluster_basedomain}"
  value      = packet_device.node[count.index].access_public_ipv4
  count      = (var.node_type == "master" ? var.node_count : 0 )
}

resource "cloudflare_record" "dns_srv_etcd" {
  zone_id    = var.cf_zone_id
  type       = "SRV"
  name       = "_etcd-server-ssl._tcp"
  count      = (var.node_type == "master" ? var.node_count : 0 )

  data = {
    service  = "_etcd-server-ssl"
    proto    = "_tcp"
    name     = "${var.cluster_name}.${var.cluster_basedomain}"
    priority = 0
    weight   = 10
    port     = 2380
    target   = "etcd-${count.index}.${var.cluster_name}.${var.cluster_basedomain}"
  }

}

resource "null_resource" "bastion_etc_hosts" {

  depends_on = [ cloudflare_record.dns_a_node ]
  count      = "${var.node_count}"

  provisioner "remote-exec" {

    connection {
      private_key = "${file("${var.ssh_private_key_path}")}"
      host        = var.bastion_ip
    }


    inline = [
      "echo '${packet_device.node[count.index].access_public_ipv4}  ${var.node_type}-${count.index}.${var.cluster_name}.${var.cluster_basedomain}' >> /etc/hosts"
    ]
  }

}

output "finished" {
  value      = "Provisioning node type ${var.node_type} finished."
}

