#!/bin/bash

### NOTE: This assumes you're TF_VAR environment variables are still set, and you've authenticated using the generated kubeconfig or valid token.

#`terraform output | grep export | tail -1 | xargs` || true

### Create project and default pull secret for Quay

cat << EOF | oc create -f -
apiVersion: v1
kind: Namespace
metadata:
  labels:
    openshift.io/cluster-monitoring: "true"
  name: quay-enterprise
spec: {}
---
apiVersion: v1
kind: Secret
metadata:
  name: redhat-quay-pull-secret
  namespace: quay-enterprise
data:
  .dockerconfigjson: ewogICJhdXRocyI6IHsKICAgICJxdWF5LmlvIjogewogICAgICAiYXV0aCI6ICJjbVZrYUdGMEszRjFZWGs2VHpneFYxTklVbE5LVWpFMFZVRmFRa3MxTkVkUlNFcFRNRkF4VmpSRFRGZEJTbFl4V0RKRE5GTkVOMHRQTlRsRFVUbE9NMUpGTVRJMk1USllWVEZJVWc9PSIsCiAgICAgICJlbWFpbCI6ICIiCiAgICB9CiAgfQp9
type: kubernetes.io/dockerconfigjson
EOF

### Create Quay OperatorGroup
###

cat << EOF | oc create -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  annotations:
    olm.providedAPIs: QuayEcosystem.v1alpha1.redhatcop.redhat.io
  generateName: quay-enterprise-
  name: quay-enterprise-og
  namespace: quay-enterprise
spec:
  targetNamespaces:
  - quay-enterprise
EOF

### Create Quay Operator Subscription
###

cat << EOF | oc create -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: quay-operator
  namespace: quay-enterprise
spec:
  channel: quay-v3.3
  installPlanApproval: Automatic
  name: quay-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: red-hat-quay.v3.3.0
EOF

### Sleep for 15s while Operator Subscription initializes
echo "Waiting for 15s while the Quay Operator Initializes"
sleep 15

### Create Quay Instance
### (Assumes you have a storage class configured, such as NFS, hostPath, or OCS)

cat << EOF | oc create -f -
apiVersion: redhatcop.redhat.io/v1alpha1
kind: QuayEcosystem
metadata:
  name: quayecosystem
  namespace: quay-enterprise
spec:
  quay:
    imagePullSecretName: redhat-quay-pull-secret
    deploymentStrategy: Recreate
    skipSetup: false
    keepConfigDeployment: true
    enableRepoMirroring: true
    registryStorage:
      persistentVolumeAccessModes:
        - ReadWriteOnce
      persistentVolumeSize: 75Gi
      persistentVolumeStorageClassName: managed-nfs-storage
    database:
      volumeSize: 10Gi
    externalAccess:
      tls:
        termination: edge
      hostname: quay.apps.${TF_VAR_cluster_name}.${TF_VAR_cluster_basedomain}
  clair:
    enabled: true
    imagePullSecretName: redhat-quay-pull-secret
EOF

cat << EOF
Default Credentials for Quay
-----------------------------
Username:   quay
Password:   password
Email:      quay@redhat.com

To enable the bridge operator follow these steps:

  (1) Generate a new organization (e.g. "Bridge")       : https://quay.apps.${TF_VAR_cluster_name}.${TF_VAR_cluster_basedomain}/organizations/new
  (2) Generate an "Application" (e.g. "Bridge")         : https://quay.apps.${TF_VAR_cluster_name}.${TF_VAR_cluster_basedomain}/organization/Bridge?tab=applications
  (3) Genearate an OAuth token choosing all permissions
  (4) Copy token to clipboard and use to enable bridge operator


To modify the superuser credentials please refer to:
https://access.redhat.com/documentation/en-us/red_hat_quay/3/html/deploy_red_hat_quay_on_openshift_with_quay_operator/customizing_your_red_hat_quay_cluster#red_hat_quay_superuser_credentials
EOF
