//output "ign_bootstrap" {
//  value = github_repository_file.gh_ocp_ign_bootstrap
//}

output "finished" {
  depends_on = [
    null_resource.ocp_approve_pending_csrs,
    null_resource.ocp_nfs_provisioner,
    null_resource.reconfig_lb,
    null_resource.reconfig_nfs_exports,
  ]
  value = "OpenShift install wait and cleanup finished"
}

