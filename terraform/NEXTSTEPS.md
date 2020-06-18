# Overview

Now that your cluster is up and running you can start tackling Day 2 operations. This assumes you're using CloudFlare for DNS, but the steps remain similar for other providers.

# Let's Encrypt Wildcard Certificates

This can be executed from your bastion host, or locally depending on your OS:

```
export KUBECONFIG="/tmp/artifacts/install/auth/kubeconfig"      ## Update to kubeconfig location

export CF_Key=$TF_VAR_cf_api_key                                ## Update to appropriate Cloudflare key (or other DNS provider cred)
export CF_Email=$TF_VAR_cf_email                                ## Update to appropriate Cloudflare email (or other DNS provider cred)

export LE_API=$(oc whoami --show-server | cut -f 2 -d ':' | cut -f 3 -d '/' | sed 's/-api././')
export LE_WILDCARD=$(oc get ingresscontroller default -n openshift-ingress-operator -o jsonpath='{.status.domain}')
export CERTDIR=$HOME/certificates

# Install acme.sh
curl https://get.acme.sh | sh

# Request certificate with dns_cf
$HOME/.acme.sh/acme.sh --issue -d ${LE_API} -d *.${LE_WILDCARD} --dns dns_cf

# Install certificate
mkdir -p ${CERTDIR}
$HOME/.acme.sh/acme.sh --install-cert -d ${LE_API} -d *.${LE_WILDCARD} --cert-file ${CERTDIR}/cert.pem --key-file ${CERTDIR}/key.pem --fullchain-file ${CERTDIR}/fullchain.pem --ca-file ${CERTDIR}/ca.cer

# Create router-certs secret and update ingresscontroller to use new cert(s)
oc create secret tls router-certs --cert=${CERTDIR}/fullchain.pem --key=${CERTDIR}/key.pem -n openshift-ingress
oc patch ingresscontroller default -n openshift-ingress-operator --type=merge --patch='{"spec": { "defaultCertificate": { "name": "router-certs" }}}'

```

# Registry Operator Update

The registry operator defaults to a state of "Removed" for bare metal installations, but if you've deployed an appropriate storage backend (e.g. `ocp_storage_nfs_enable`) you can patch the registry operator configuration:

```
oc patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"managementState": "Managed", "storage":{"pvc":{"claim":""}}}}'

## Optionally, enable the default route:
oc patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"defaultRoute":true}}'

```

# OpenShift Virtualization (CNV/kubevirt)

If you're interested in evaluating OpenShift virtualization, enable the appropriate operator and subscription using the `extras` provided:

```
oc apply -f extras/cnv/1_cnv_operator_subscription.yaml

## Optionally, enable hostPath provisioner (recommended/required if not using OCS)
oc apply -f extras/cnv/2_cnv_hostpath_provisioner.yaml
```

