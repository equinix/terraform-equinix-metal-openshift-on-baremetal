[![terraform](https://github.com/equinix/terraform-equinix-metal-openshift-on-baremetal/actions/workflows/terraform.yaml/badge.svg)](https://github.com/equinix/terraform-equinix-metal-openshift-on-baremetal/actions/workflows/terraform.yaml)
[![](https://img.shields.io/badge/stability-experimental-red.svg)](https://github.com/equinix-labs/equinix-labs/blob/main/experimental-statement.md#experimental-statement)

# OpenShift via Terraform on Equinix Metal

This collection of modules will deploy a bare metal [OpenShift](https://docs.openshift.com/container-platform/latest/installing/installing_bare_metal/installing-bare-metal.html) environment consisting of (1) ephemeral bootstrap node, (3) control plane nodes, and a user-configured count of worker nodes<sup>[1](#3nodedeployment)</sup> on [Equinix Metal](https://deploy.equinix.com). DNS records are automatically configured using [Cloudflare](http://cloudflare.com), AWS Route53, or Linode DNS.

## Install

With your [Equinix Metal account, project, and a **User** API token](https://deploy.equinix.com/developers/docs/metal/identity-access-management/users/), you can use [Terraform v1+](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) to install a proof-of-concept demonstration environment for OpenShift on Equinix Metal.

### Additional requirements

`local-exec` provisioners require the use of:

- `curl` ([install instructions](https://everything.curl.dev/get))
- `jq` ([install instructions](https://stedolan.github.io/jq/download/))

## Download this project

To download this project, run the following command:

```bash
git clone https://github.com/equinix/terraform-equinix-metal-openshift-on-baremetal.git
cd terraform-equinix-metal-openshift
```

## Usage

1. Follow [this](EQUINIX.md) to configure your Equinix Metal project and collect required parameters.

1. Follow [this](CLOUDFLARE.md) to configure your Cloudflare account and collect required parameters (AWS and Linode DNS options are also available).

1. [Obtain an OpenShift Cluster Manager API Token](https://cloud.redhat.com/openshift/token) for pullSecret generation.

1. Configure TF_VARs applicable to your Equinix Metal project, DNS settings, and OpenShift API Token:

    ```bash
    export TF_VAR_metal_project_id="fake-uuid-4159-8488-19910kj"
    export TF_VAR_metal_auth_token="faketokenAP8957Abny01051"
    ```

    If you have the [Metal CLI](https://deploy.equinix.com/labs/metal-cli) installed, you can use `eval $(metal env --export -o terraform)` to use the token and project configured for use by Metal CLI.

    ```bash
    export TF_VAR_cluster_basedomain="domain.com"
    export TF_VAR_ocp_cluster_manager_token="eyJhbGc...d8Agva" # https://cloud.redhat.com/openshift/token
    export TF_VAR_dns_provider="cloudflare" # aws and linode are also offered
    ```

    Alternatively, copy `terraform.tfvars.example` to `terraform.tfvars` and modify the values in that file accordingly.

1. Initialize and validate terraform:

    ```bash
    terraform init -upgrade
    terraform validate
    ```

1. Provision all resources and start the installation. This process takes between 30 and 50 minutes:

    ```bash
    terraform apply
    ```

    The Terraform output will look like the following after a successful deployment:

    ```console
    Apply complete! Resources: X added, 0 changed, 0 destroyed.

    Outputs:

    Information = <<EOT


    OpenShift cluster deployed.
    Access the OpenShift Web Console at: https://console-openshift-console.apps.cluster_name.cluster_base_domain.examples.com

    Username: kubeadmin
    Password: secret-password

    To use the CLI (on bastion):
        export KUBECONFIG="/tmp/artifacts/install/auth/kubeconfig"

    To use the CLI (locally):
        export KUBECONFIG="/Users/username/src/terraform-equinix-metal-openshift-on-baremetal/auth/kubeconfig"

    Review your nodes:
        oc get nodes


    EOT
    bastion_ip = "198.51.100.32"
    bastion_kubeconfig = "/tmp/artifacts/install/auth/kubeconfig"
    console = "https://console-openshift-console.apps.cluster_name.cluster_base_domain.examples.com"
    kubeconfig = "/Users/mjohansson/dev/terraform-equinix-metal-openshift-on-baremetal/auth/kubeconfig"
    openshift_bootstrap_ip = [
    "198.51.100.38",
    ]
    openshift_controlplane_ips = [
    [
        "198.51.100.70",
        "203.0.113.23",
        "192.0.2.30",
    ],
    ]
    openshift_worker_ips = [
    [
        "198.51.100.12",
        "203.0.113.98",
    ],
    ]
    password = <sensitive>
    ssh_private_key_file = "/Users/username/.ssh/id_rsa_mos-mx94n"
    ssh_public_key = "ssh-rsa AAAA...=="
    username = "kubeadm"
    ```

    To view this output later, use `terraform output`.

1. Cleanup the boostrap node once provisioning and installation is complete by permanently (recommended) or temporarily setting `count_bootstrap=0`

    ```bash
    export TF_VAR_count_bootstrap=0 # use the terraform.tfvars file to persist this change
    terraform apply
    ```

    If you need to obtain your `kubeadmin` credentials at a later time:

    ```sh
    terraform output -raw password
    ```

1. Login to the various nodes via SSH

    Bastion:

    ```sh
    ssh -i $(terraform output -raw ssh_private_key_file) root@$(terraform output -raw bastion_ip)
    ```

   Bootstrap Node:

   ```sh
   ssh -i $(terraform output -raw ssh_private_key_file) core@$(terraform output -json openshift_bootstrap_ip | jq -r '.[0]')
   ```

   Three Control Plane Nodes (default, 0-2):

   ```sh
   ssh -i $(terraform output -raw ssh_private_key_file) core@$(terraform output -json openshift_controlplane_ips | jq -r '.[0].[0]') # Change the last 0 for other nodes
   ```

   Two Worker Nodes (default, 0-1):

   ```sh
   ssh -i $(terraform output -raw ssh_private_key_file) core@$(terraform output -json openshift_worker_ips | jq -r '.[0].[0]') # Change the last 0 for other nodes
   ```

1. Access the console (MacOS, Linux)

   ```sh
   open $(terraform output -raw console)
   ```

   You will have to navigate your browser settings to access the URL with an invalid certificate.

1. View OpenShift nodes with Kubernetes CLI (`kubectl`)

   ```sh
   % kubectl --kubeconfig $(terraform output -raw kubeconfig) get nodes
   NAME                   STATUS   ROLES                  AGE     VERSION
   master-0.mos.meyu.us   Ready    control-plane,master   6h28m   v1.25.16+306a47e
   master-1.mos.meyu.us   Ready    control-plane,master   6h28m   v1.25.16+306a47e
   master-2.mos.meyu.us   Ready    control-plane,master   6h28m   v1.25.16+306a47e
   worker-0.mos.meyu.us   Ready    worker                 6h17m   v1.25.16+306a47e
   worker-1.mos.meyu.us   Ready    worker                 6h14m   v1.25.16+306a47e
   ```

---

<a name="3nodedeployment"><sup>1</sup></a> As of OpenShift Container Platform 4.12 you can [deploy three-node clusters on bare metal](https://docs.openshift.com/container-platform/4.12/installing/installing_bare_metal/installing-bare-metal.html#installing-bare-metal). Setting `count_compute=0` will support deployment of a 3-node cluster. [↩](#openshift-via-terraform-on-equinix-metal)
