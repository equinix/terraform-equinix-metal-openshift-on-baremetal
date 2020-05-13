
module "prepare_openshift" {
  source = "./modules/prereq"

  cluster_name         = "${var.cluster_name}"
  cluster_basedomain   = "${var.cluster_basedomain}"
  count_master         = "${var.count_master}"
  count_compute        = "${var.count_compute}"
  ssh_public_key_path = "${var.ssh_public_key_path}"

}

//resource "null_resource" "ocp_installer" {
//  provisioner "local-exec" {
//	command = "[ -f artifacts/openshift-install.tar.gz ] && (echo 'Openshift Installer Exists') || (mkdir artifacts; curl http://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-${var.ocp_version}/openshift-install-linux.tar.gz --output artifacts/openshift-install.tar.gz; cd artifacts; tar -xvzf openshift-install.tar.gz;)"
//  }
//}
