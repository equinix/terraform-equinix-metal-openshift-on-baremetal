#!/bin/bash

### NOTE: This assumes you've deployed a minimum of (3) worker nodes

### Create project and operator prereq's for OCS

cat << EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
  labels:
    openshift.io/cluster-monitoring: "true"
  name: openshift-storage
spec: {}
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-storage-operatorgroup
  namespace: openshift-storage
spec:
  serviceAccount:
    metadata:
      creationTimestamp: null
  targetNamespaces:
  - openshift-storage
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ocs-operator
  namespace: openshift-storage
spec:
  channel: stable-4.4
  installPlanApproval: Automatic
  name: ocs-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

### Sleep for 15s while Operator Subscription initializes
echo "Waiting for 15s while the OCS Operator Initializes"
sleep 15
