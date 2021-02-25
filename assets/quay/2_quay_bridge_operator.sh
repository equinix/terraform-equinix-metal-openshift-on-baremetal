#!/bin/bash

### NOTE: You must provide an OAuth2 Token from Quay for proper configuration

if [ $# -eq 0 ]
  then
    echo "No arguments supplied. You must supply the OAuth2 Token from a configured Quay Application to enable the bridge operator."
    exit 1
fi

TOKEN=($1)
CA_BUNDLE=(`oc get configmap -n kube-system extension-apiserver-authentication -o=jsonpath='{.data.client-ca-file}' | base64 | tr -d '\n'`)

### Create secret with OAuth2 Token
oc create secret generic quay-integration --from-literal=token=${TOKEN} -n openshift-operators


### Create Quay Bridge Service
###
cat << EOF | oc apply -f -
apiVersion: v1
kind: Service
metadata:
  labels:
    name: quay-bridge-operator
  name: quay-bridge-operator
  namespace: openshift-operators
spec:
  ports:
    - name: https
      port: 443
      protocol: TCP
      targetPort: 8443
  selector:
    name: quay-bridge-operator
  sessionAffinity: None
  type: ClusterIP
EOF

./webhook-create-signed-cert.sh --namespace openshift-operators --secret quay-bridge-operator-webhook-certs --service quay-bridge-operator

### Create Quay MutatingWebHookConfiguration

cat << EOF | oc apply -f -
apiVersion: admissionregistration.k8s.io/v1beta1
kind: MutatingWebhookConfiguration 
metadata:
  name: quay-bridge-operator
webhooks:
  - name: quayintegration.redhatcop.redhat.io
    clientConfig: 
      service:
        namespace: openshift-operators
        name: quay-bridge-operator
        path: "/admissionwebhook"
      caBundle: "${CA_BUNDLE}"
    rules: 
    - operations:  [ "CREATE" ]
      apiGroups: [ "build.openshift.io" ]
      apiVersions: ["v1" ]
      resources: [ "builds" ]
    failurePolicy: Fail
EOF

### Create Quay Bridge Operator Subscription
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: quay-bridge-operator
  namespace: openshift-operators
spec:
  channel: quay-v3.3
  installPlanApproval: Automatic
  name: quay-bridge-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: quay-bridge-operator.v3.3.0
EOF

### Create Quay Integration

cat <<EOF | oc apply -f -
apiVersion: redhatcop.redhat.io/v1alpha1
kind: QuayIntegration
metadata:
  name: pckt-quayintegration
spec:
  clusterID: ${TF_VAR_cluster_name}
  credentialsSecretName: openshift-operators/quay-integration
  quayHostname: https://quay.apps.${TF_VAR_cluster_name}.${TF_VAR_cluster_basedomain}
  insecureRegistry: true
EOF

### Create Quay Container Security Operator
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: container-security-operator
  namespace: openshift-operators
spec:
  channel: quay-v3.3
  installPlanApproval: Automatic
  name: container-security-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: container-security-operator.v3.3.0
EOF