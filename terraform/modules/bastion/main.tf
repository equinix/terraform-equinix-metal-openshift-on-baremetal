variable "plan" {}
variable "node_count" {}
variable "facility" {}
variable "cluster_name" {}
variable "ssh_private_key_path" {}
variable "project_id" {}
variable "cf_zone_id" {}

//resource "packet_reserved_ip_block" "ip_bootstrap" {
//  project_id = "${var.project_id}"
//  facility   = "${var.facility}"
//  quantity   = 2 //var.node_count
//}

resource "packet_device" "openshift_bootstrap" {
  hostname           = "${format("bootstrap-%01d.${var.cluster_name}", count.index)}"
  operating_system   = "custom_ipxe"
  ipxe_script_url    = "http://shifti.us/ipxe/"
  //ipxe_script_url  = "http://shifti.us/ipxe/?ip=${cidrhost(packet_reserved_ip_block.ip_bootstrap.cidr_notation,1)}&gw=${packet_reserved_ip_block.ip_bootstrap.network}&netmask=${packet_reserved_ip_block.ip_bootstrap.netmask}&hostname=${format("bootstrap-%01d.${var.cluster_name}", count.index)}"
  plan               = "${var.plan}"
  facilities         = ["${var.facility}"]
  count              = "${var.node_count}"

  always_pxe         = true

//  ip_address {
//     type = "public_ipv4"
//     cidr = 31
//     reservation_ids = [packet_reserved_ip_block.ip_bootstrap.id]
//  }
//  ip_address {
//     type = "private_ipv4"
//  }

  billing_cycle    = "hourly"
  project_id       = "${var.project_id}"
  user_data        = "${file("${path.module}/bootstrap.ign")}"
}

resource "cloudflare_record" "dns_a_bootstrap" {
  zone_id    = "${var.cf_zone_id}"
  type       = "A"
  name       = "bootstrap-${count.index}.${var.cluster_name}"
  value      = "${packet_device.openshift_bootstrap[count.index].access_public_ipv4}"
  count      = "${var.node_count}"
}


