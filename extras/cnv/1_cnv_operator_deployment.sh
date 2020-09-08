#!/bin/bash

## Create local-storage namespace and subscription to Local Storage operator
cat << EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
  labels:
    openshift.io/cluster-monitoring: "true"
  name: openshift-cnv
spec: {}
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-cnv-group
  namespace: openshift-cnv
spec:
  targetNamespaces:
  - openshift-cnv
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kubevirt-hyperconverged
  namespace: openshift-cnv
spec:
  channel: "2.3"
  installPlanApproval: Automatic
  name: kubevirt-hyperconverged
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

### Sleep for 15s while Operator Subscription initializes
echo "Waiting for 20s while the Operator Initializes"
sleep 20

cat << EOF | oc apply -f -
apiVersion: hco.kubevirt.io/v1alpha1
kind: HyperConverged
metadata:
  name: kubevirt-hyperconverged
  namespace: openshift-cnv
spec:
  BareMetalPlatform: true
EOF

## Optional - hostPathProvisioner if not using OCS

cat << EOF | oc apply -f -
apiVersion: hostpathprovisioner.kubevirt.io/v1alpha1
kind: HostPathProvisioner
metadata:
  name: hostpath-provisioner
spec:
  imagePullPolicy: IfNotPresent
  pathConfig:
    path: "/var/lib/kubevirt"
    useNamingPrefix: "false"
---
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  name: 50-set-selinux-for-hostpath-provisioner
  labels:
    machineconfiguration.openshift.io/role: worker
spec:
  config:
    ignition:
      version: 2.2.0
    systemd:
      units:
        - contents: |
            [Unit]
            Description=Set SELinux chcon for hostpath provisioner
            Before=kubelet.service
            [Service]
            ExecStart=/usr/bin/chcon -Rt container_file_t /var/lib/kubevirt
            [Install]
            WantedBy=multi-user.target
          enabled: true
          name: hostpath-provisioner.service
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: hostpath-provisioner 
provisioner: kubevirt.io/hostpath-provisioner
reclaimPolicy: Delete 
volumeBindingMode: WaitForFirstConsumer
EOF