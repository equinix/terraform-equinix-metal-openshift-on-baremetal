variable "plan" {}
variable "node_count" {}
variable "facility" {}
variable "cluster_name" {}
variable "ssh_private_key_path" {}
variable "project_id" {}

resource "packet_device" "openshift_bootstrap" {
  hostname         = "${format("${var.cluster_name}-${var.facility}-bootstrap--%02d", count.index)}"
  operating_system = "custom_ipxe"
  ipxe_script_url  = "https://raw.githubusercontent.com/RedHatSI/openshift-packet-deploy/bootstrap-test/ipxe/rhcos-packet.ipxe"
  plan             = "${var.plan}"
  facilities       = ["${var.facility}"]
  count            = "${var.node_count}"

  billing_cycle = "hourly"
  project_id    = "${var.project_id}"
}
