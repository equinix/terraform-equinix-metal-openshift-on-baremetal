# Next Steps

Now that your cluster is up and running you can start tackling Day 2 operations such as deploying signed certificates for select components, initializing the integrated registry, and/or scaling your compute or storage nodes. Some of these procedures assume you're using CloudFlare for DNS, but the steps remain similar for other providers.

## Scaling Compute

Adding worker nodes to your cluster on Equinix Metal is trivial since the provisioning process is largely automated, but there are supplemental considerations if your cluster has been running for more than 24+ hours: https://access.redhat.com/solutions/4799921. 

If your cluster has been deployed/running for *less than 24 hours* you can scale compute by incrementing the `count_compute` value in `vars.tf` or your sourced environment including `TF_VAR_count_compute` and rerunning `terraform apply`. For example, if you initially deploy 3 worker compute nodes by setting `TF_VAR_count_compute=3` and you'd like to scale to 5 nodes, you would simply re-execute your terraform apply (*NOTE: this example does NOT persist the count value for your compute nodes. You should permanently set `count_compute` or `TF_VAR_count_compute`*:
```bash
export KUBECONFIG="/tmp/artifacts/install/auth/kubeconfig"      ## Update to kubeconfig location

# Scale-up -- NOTE: You should permanently set `count_compute` or `TF_VAR_count_compute`
terraform apply -var="count_compute=5" -var="count_bootstrap=0" --auto-approve

# Post-provisioning
oc get csr -oname | xargs oc adm certificate approve
```


If your cluster has been deploymed/running for *24 hours or more* you must update your bastion-hosted `worker.ign` file before scaling:
```bash
export KUBECONFIG="/tmp/artifacts/install/auth/kubeconfig"      ## Update to kubeconfig location
source ~/.metal-vars

# Pre-scaling
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${TF_VAR_ssh_private_key_path} root@lb-0.${TF_VAR_cluster_name}.${TF_VAR_cluster_basedomain} << EOF
    echo \"q\" | openssl s_client -connect api.${TF_VAR_cluster_name}.${TF_VAR_cluster_basedomain}:22623  -showcerts | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' | base64 --wrap=0 | tee ./api-int.base64 && \
sed --regexp-extended --in-place=.backup "s%base64,[^,]+%base64,$(cat ./api-int.base64)\"%" /usr/share/nginx/html/worker.ign
EOF

# Scale-up -- NOTE: You should permanently set `count_compute` or `TF_VAR_count_compute`
terraform apply -var="count_compute=5" -var="count_bootstrap=0" --auto-approve

# Post-provisioning
oc get csr -oname | xargs oc adm certificate approve
```

## Let's Encrypt Wildcard Certificates

This can be executed from your bastion host, or locally depending on your OS:

Shortcut using existing `TF_VAR_` variables:
```bash
bash assets/1_configure_ingresscerts.sh
```

Optionally customize the parameters/variables before execution:
```bash
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

## Registry Operator Update

The registry operator defaults to a state of "Removed" for bare metal installations, but if you've deployed an appropriate storage backend (e.g. `ocp_storage_nfs_enable`) you can patch the registry operator configuration:

```
oc patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"managementState": "Managed", "storage":{"pvc":{"claim":""}}}}'

## Optionally, enable the default route:
oc patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"defaultRoute":true}}'

```

## OpenShift Virtualization (CNV/kubevirt)

If you're interested in evaluating OpenShift virtualization, enable the appropriate operator and subscription using the `assets` provided:

```
oc apply -f assets/cnv/1_cnv_operator_subscription.yaml

## Optionally, enable hostPath provisioner (recommended/required if not using OCS)
oc apply -f assets/cnv/2_cnv_hostpath_provisioner.yaml
```

## Troubleshooting

### Equinix Metal

If you encounter issues with a specific Equinix Metal host you may need to leverage Equinix Metal's *Out-of-Band Console* to troubleshoot. This is slightly difficult given CoreOS reverts the initial serial console target, which we configure as `console=ttyS1,115200n8` during *Custom iPXE* boot. After successful installation of CoreOS this is reverted to the default `console=ttyS0,115200n8`. While rebooting a host you can modify the kernel command line argument by hitting `e` when you see the grub menu entry for CoreOS. Change `ttyS0` to `ttyS1` and press `CTL+X` to continue booting.

