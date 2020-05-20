variable "plan" {}
variable "node_count" {}
variable "facility" {}
variable "cluster_name" {}
variable "ssh_private_key_path" {}
variable "project_id" {}
variable "cf_zone_id" {}
variable "bastion_ip" {}

resource "packet_device" "bootstrap" {
  hostname           = "${format("bootstrap-%01d.${var.cluster_name}", count.index)}"
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
  name       = "bootstrap-${count.index}.${var.cluster_name}"
  value      = "${packet_device.bootstrap[count.index].access_public_ipv4}"
  count      = "${var.node_count}"
}


