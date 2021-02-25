//output "ign_bootstrap" {
//  value = github_repository_file.gh_ocp_ign_bootstrap
//}

output "finished" {
  depends_on = [null_resource.ocp_install_manifests]
  value      = "OpenShift manifest and ignition creation finshed. Bastion IP: ${var.bastion_ip}"
}


