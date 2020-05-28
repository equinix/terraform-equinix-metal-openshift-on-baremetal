#!/bin/bash

RDIR=$1
BASTION_IP=$2

# Set OCP credential
export KUBECONFIG=$RDIR/artifacts/install/auth/kubeconfig;

# Pull NFS Provisioner manifests
curl https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/rbac.yaml > $RDIR/artifacts/install/nfsp-rbac.yaml
curl https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/deployment.yaml > $RDIR/artifacts/install/nfsp-deployment.yaml
curl https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/class.yaml > $RDIR/artifacts/install/nfsp-class.yaml

# Retarget oc binary
export oc=$RDIR/artifacts/oc

# Create NFS Provisioner namespace
$oc create namespace openshift-nfs-storage
$oc label namespace openshift-nfs-storage "openshift.io/cluster-monitoring=true"

NAMESPACE=`$oc project openshift-nfs-storage -q`

# Update manifests to use BASTION_IP, proper NFS dirs, proper NAMESPACE, and custom class name
sed -i'' "s/namespace:.*/namespace: $NAMESPACE/g" $RDIR/artifacts/install/nfsp-rbac.yaml
sed -i'' "s/namespace:.*/namespace: $NAMESPACE/g" $RDIR/artifacts/install/nfsp-deployment.yaml
sed -i'' "s/10.10.10.60/$BASTION_IP/g" $RDIR/artifacts/install/nfsp-deployment.yaml
sed -i'' "s/fuseim.*/storage.io\/nfs/g" $RDIR/artifacts/install/nfsp-deployment.yaml
sed -i'' "s/\/ifs\/kubernetes/\/mnt\/nfs\/ocp/g" $RDIR/artifacts/install/nfsp-deployment.yaml
sed -i'' "s/fuseim.*/storage.io\/nfs/g" $RDIR/artifacts/install/nfsp-deployment.yaml
sed -i'' "s/fuseim.*/storage.io\/nfs/g" $RDIR/artifacts/install/nfsp-class.yaml

# Apply manifests and set appropriate permissions
$oc create -f $RDIR/artifacts/install/nfsp-rbac.yaml
$oc adm policy add-scc-to-user hostmount-anyuid system:serviceaccount:$NAMESPACE:nfs-client-provisioner
$oc create -f $RDIR/artifacts/install/nfsp-class.yaml
$oc create -f $RDIR/artifacts/install/nfsp-deployment.yaml

# Set class as cluster-wide default
$oc patch storageclass managed-nfs-storage -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'
