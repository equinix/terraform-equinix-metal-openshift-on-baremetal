apiVersion: v1
baseDomain: ${cluster_basedomain}
metadata:
  name: ${cluster_name}
networking:
  clusterNetworks:
  - cidr: 10.254.0.0/16
    hostPrefix: 24
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
compute:
- hyperthreading: Enabled   
  name: worker
  replicas: ${count_compute}
controlPlane:
  hyperthreading: Enabled   
  name: master
  replicas: ${count_master}
platform:
  none: {}
sshKey: '${trimspace(file("${ssh_public_key_path}"))}'