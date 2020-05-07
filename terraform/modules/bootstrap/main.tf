variable "plan" {}
variable "node_count" {}
variable "facility" {}
variable "cluster_name" {}
variable "ssh_private_key_path" {}
variable "project_id" {}
variable "cf_zone_id" {}

resource "packet_device" "openshift_bootstrap" {
  hostname         = "${format("${var.cluster_name}-${var.facility}-bootstrap-%02d", count.index)}"
  operating_system = "custom_ipxe"
  ipxe_script_url  = "https://raw.githubusercontent.com/RedHatSI/openshift-packet-deploy/bootstrap-test/ipxe/rhcos-packet.ipxe"
  plan             = "${var.plan}"
  facilities       = ["${var.facility}"]
  count            = "${var.node_count}"

  billing_cycle = "hourly"
  project_id    = "${var.project_id}"
}

resource "cloudflare_record" "dns_a_bootstrap" {
  depends_on = [packet_device.openshift_bootstrap]
  zone_id    = "${var.cf_zone_id}"
  type       = "A"
  name       = "bootstrap-${count.index}.${var.cluster_name}"
  value      = "${packet_device.openshift_bootstrap[count.index].access_public_ipv4}"
  count      = "${var.node_count}"
}


