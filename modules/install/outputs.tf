//output "ign_bootstrap" {
//  value = github_repository_file.gh_ocp_ign_bootstrap
//}

output "finished" {
  depends_on = [null_resource.ocp_install_wait_for_bootstrap, null_resource.ocp_bootstrap_cleanup, null_resource.ocp_installer_wait_for_completion]
  value      = "OpenShift install wait and cleanup finished"
}

