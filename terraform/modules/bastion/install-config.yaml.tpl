apiVersion: v1
baseDomain: ${cluster_base_domain}
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
  replicas: 0
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: ${count_master}

pullSecret: '${cluster_pullSecret}'
sshKey: '${key}'
