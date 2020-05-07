variable "plan" {}
variable "node_count" {}
variable "facility" {}
variable "cluster_name" {}
variable "ssh_private_key_path" {}
variable "project_id" {}
variable "cf_zone_id" {}

resource "packet_reserved_ip_block" "ip_bootstrap" {
  project_id = "${var.project_id}"
  facility = "${var.facility}"
  quantity = var.node_count
}

resource "packet_device" "openshift_bootstrap" {
  hostname         = "${format("${var.cluster_name}-${var.facility}-bootstrap-%02d", count.index)}"
  operating_system = "custom_ipxe"
  ipxe_script_url  = "https://ipxe-boot-shiftius.apps.us-west-1.starter.openshift-online.com/boot.php?ip=${join("/", [cidrhost(packet_reserved_ip_block.ip_bootstrap.cidr_notation,0), "32"])}&netmask=${packet_reserved_ip_block.ip_bootstrap.netmask}&hostname=${format("${var.cluster_name}-${var.facility}-bootstrap-%02d", count.index)}"
  // ipxe_script_url  = "https://raw.githubusercontent.com/RedHatSI/openshift-packet-deploy/bootstrap-test/ipxe/rhcos-packet.ipxe"
  plan             = "${var.plan}"
  facilities       = ["${var.facility}"]
  count            = "${var.node_count}"

  ip_address {
     type = "public_ipv4"
     cidr = 32
     reservation_ids = [packet_reserved_ip_block.ip_bootstrap.id]
  }
  ip_address {
     type = "private_ipv4"
  }

  billing_cycle    = "hourly"
  project_id       = "${var.project_id}"
  user_data        = "${file("${path.module}/bootstrap.ign")}"
}

resource "cloudflare_record" "dns_a_bootstrap" {
  depends_on = [packet_device.openshift_bootstrap]
  zone_id    = "${var.cf_zone_id}"
  type       = "A"
  name       = "bootstrap-${count.index}.${var.cluster_name}"
  value      = "${packet_device.openshift_bootstrap[count.index].access_public_ipv4}"
  count      = "${var.node_count}"
}


