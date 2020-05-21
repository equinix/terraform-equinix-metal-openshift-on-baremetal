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

resource "packet_device" "node" {
  hostname           = "${format("${var.node_type}-%01d.${var.cluster_name}.${var.cluster_basedomain}", count.index)}"
  operating_system   = "custom_ipxe"
  ipxe_script_url    = "http://shifti.us/ipxe/?ep=${var.bastion_ip}&node=${var.node_type}"
  plan               = "${var.plan}"
  facilities         = ["${var.facility}"]
  count              = "${var.node_count}"

  billing_cycle    = "hourly"
  project_id       = "${var.project_id}"

  //user_data        = "${file("${path.root}/artifacts/bootstrap.ign")}"
}

resource "cloudflare_record" "dns_a_node" {
  zone_id    = "${var.cf_zone_id}"
  type       = "A"
  name       = "${var.node_type}-${count.index}.${var.cluster_name}.${var.cluster_basedomain}"
  value      = "${packet_device.node[count.index].access_public_ipv4}"
  count      = "${var.node_count}"
}

