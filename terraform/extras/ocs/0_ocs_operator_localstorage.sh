#!/bin/bash

### NOTE: This assumes you've deployed a minimum of (3) worker nodes

## Label worker nodes for storage
oc get nodes -l node-role.kubernetes.io/worker -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | awk '{system("oc label nodes " $1 " cluster.ocs.openshift.io/openshift-storage=\047\047")}'

## Discover Block devices with no filesystem and that isn't configured with a partition
## This is not granular -- it adds all unused block devices

unset WORKER_DISKS
for i in {0..2}; do
  #export WORKER_DISKS+='        - /dev/disk/by-id/'
  export WORKER_DISKS+=$(ssh -q  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${TF_VAR_ssh_private_key_path} core@worker-${i}.${TF_VAR_cluster_name}.${TF_VAR_cluster_basedomain} "lsblk -o NAME,FSTYPE -dsn | awk '\$2 == \"\" {print \$1}' | grep -v -e '[0-9]' | awk '{system(\"ls -l /dev/disk/by-id/ | grep \" \$1 \" | head -1\")}' | awk '{print(\"        - /dev/disk/by-id/\" \$9)}'")
  export WORKER_DISKS+="\n"
done

## Create local-storage namespace and subscription to Local Storage operator
cat << EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
  labels:
  name: local-storage
spec: {}
---
apiVersion: operators.coreos.com/v1alpha2
kind: OperatorGroup
metadata:
  name: local-operator-group
  namespace: local-storage
spec:
  targetNamespaces:
    - local-storage
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: local-storage-operator
  namespace: local-storage
spec:
  channel: "4.4"
  installPlanApproval: Automatic
  name: local-storage-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

### Sleep for 15s while Operator Subscription initializes
echo "Waiting for 15s while the Local Storage Operator Initializes"
sleep 15

## Configure LocalVolume CR

export LVCR="
apiVersion: local.storage.openshift.io/v1
kind: LocalVolume
metadata:
  name: local-block
  namespace: local-storage
spec:
  nodeSelector:
    nodeSelectorTerms:
    - matchExpressions:
        - key: cluster.ocs.openshift.io/openshift-storage
          operator: In
          values:
          - \"\"
  storageClassDevices:
    - storageClassName: localblock
      volumeMode: Block
      devicePaths:
"
export LVCR+=$(echo -e "${WORKER_DISKS}")

echo "${LVCR}" | oc apply -f -

