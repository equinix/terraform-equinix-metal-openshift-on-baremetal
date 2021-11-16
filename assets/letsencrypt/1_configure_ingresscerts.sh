#!/bin/bash

### NOTE: This assumes you're TF_VAR environment variables are still set, and you've authenticated using the generated kubeconfig or valid token.

export CF_Key=$TF_VAR_cf_api_key                                ## Update to appropriate Cloudflare key (or other DNS provider cred)
export CF_Email=$TF_VAR_cf_email                                ## Update to appropriate Cloudflare email (or other DNS provider cred)

export LE_API=$(oc whoami --show-server | cut -f 2 -d ':' | cut -f 3 -d '/' | sed 's/-api././')
export LE_WILDCARD=$(oc get ingresscontroller default -n openshift-ingress-operator -o jsonpath='{.status.domain}')
export CERTDIR=$HOME/certificates

# Install acme.sh
curl https://get.acme.sh | sh -s -- install --force

# Configure ZeroSSL account via email
$HOME/.acme.sh/acme.sh --register-account -m ${CF_Email}

# Set default CA to Let's Encrypt
$HOME/.acme.sh/acme.sh --set-default-ca --server letsencrypt
 
# Request certificate with dns_cf
$HOME/.acme.sh/acme.sh --issue -d ${LE_API} -d *.${LE_WILDCARD} --dns dns_cf

# Install certificate
mkdir -p ${CERTDIR}
$HOME/.acme.sh/acme.sh --install-cert -d ${LE_API} -d *.${LE_WILDCARD} --cert-file ${CERTDIR}/cert.pem --key-file ${CERTDIR}/key.pem --fullchain-file ${CERTDIR}/fullchain.pem --ca-file ${CERTDIR}/ca.cer

# Create router-certs secret and update ingresscontroller to use new cert(s)
oc create secret tls router-certs --cert=${CERTDIR}/fullchain.pem --key=${CERTDIR}/key.pem -n openshift-ingress
oc patch ingresscontroller default -n openshift-ingress-operator --type=merge --patch='{"spec": { "defaultCertificate": { "name": "router-certs" }}}'
