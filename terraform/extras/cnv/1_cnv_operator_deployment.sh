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
  startingCSV: kubevirt-hyperconverged-operator.v2.3.0
---
apiVersion: hco.kubevirt.io/v1alpha1
kind: HyperConverged
metadata:
  name: kubevirt-hyperconverged
  namespace: openshift-cnv
spec:
  BareMetalPlatform: true
EOF

## Stage a Windows 2016 image from Vagrant
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${TF_VAR_ssh_private_key_path} root@lb-0.${TF_VAR_cluster_name}.${TF_VAR_cluster_basedomain} << EOF
    curl -L https://app.vagrantup.com/peru/boxes/windows-server-2016-standard-x64-eval/versions/20200601.01/providers/libvirt.box -o /usr/share/nginx/html/libvirt.box
    cd /usr/share/nginx/html && tar xvzf libvirt.box
EOF

echo "Image avaialble"