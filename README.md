[![Terraform CI](https://github.com/equinix/terraform-metal-openshift-on-baremetal/workflows/Terraform%20CI/badge.svg)](https://github.com/equinix/terraform-metal-openshift-on-baremetal/actions?query=workflow%3A%22Terraform+CI%22) [![](https://img.shields.io/badge/stability-experimental-red.svg)](#experimental-statatement)

# OpenShift via Terraform on Equinix Metal

This collection of modules will deploy a bare metal [OpenShift](https://docs.openshift.com/container-platform/latest/installing/installing_bare_metal/installing-bare-metal.html) consisting of (1) ephemeral bootstrap node, (3) control plane nodes, and a user-configured count of worker nodes<sup>[1](#3nodedeployment)</sup> on [Equinix Metal](https://deploy.equinix.com). DNS records are automatically configured using [Cloudflare](http://cloudflare.com).

## Install

With your [Equinix Metal account, project, and a **User** API token](https://metal.equinix.com/developers/docs/accounts/users/), you can use [Terraform v1+](https://learn.hashicorp.com/tutorials/terraform/install-cli) to install a proof-of-concept demonstration environment for OpenShift on Equinix Metal.

### Additional requirements

`local-exec` provisioners require the use of:

- `curl` ([install instructions](https://everything.curl.dev/get))
- `jq` ([install instructions](https://stedolan.github.io/jq/download/))

## Download this project

To download this project, run the following command:

```bash
git clone https://github.com/equinix/terraform-metal-openshift-on-baremetal.git
cd terraform-metal-openshift
```

## Usage

1. Follow [this](EQUINIX.md) to configure your Equinix Metal project and collect required parameters.

1. Follow [this](CLOUDFLARE.md) to configure your Cloudflare account and collect required parameters.

1. [Obtain an OpenShift Cluster Manager API Token](https://cloud.redhat.com/openshift/token) for pullSecret generation.

1. Configure TF_VARs applicable to your Equinix Metal project, DNS settings, and OpenShift API Token:

    ```bash
    export TF_VAR_project_id="kajs886-l59-8488-19910kj"
    export TF_VAR_auth_token="lka6702KAmVAP8957Abny01051"

    export TF_VAR_cluster_basedomain="domain.com"
    export TF_VAR_ocp_cluster_manager_token="eyJhbGc...d8Agva"
    export TF_VAR_dns_provider="cloudflare" # aws and linode are also supported
    export TF_VAR_dns_options='{"email": "abc@xyz.com", "api_key": "...", "api_token": "..."}' # fields differ by DNS provider
    ```

1. Initialize and validate terraform:

    ```bash
    terraform init -upgrade
    terraform validate
    ```

1. Provision all resources and start the installation. This process takes between 30 and 50 minutes:

    ```bash
    terraform apply
    ```

1. Cleanup the boostrap node once provisioning and installation is complete by permanently (recommended) or temporarily setting `count_bootstrap=0`

    ```bash
    terraform apply -var="count_bootstrap=0"
    ```

    If you need to obtain your `kubeadmin` credentials at a later time:

    ```sh
    terraform output
    ```

## Experimental Statement

This repository is [Experimental](https://github.com/packethost/standards/blob/master/experimental-statement.md)!

---

<a name="3nodedeployment"><sup>1</sup></a> As of OpenShift Container Platform 4.5 you can [deploy three-node clusters on bare metal](https://docs.openshift.com/container-platform/4.5/installing/installing_bare_metal/installing-bare-metal.html#installation-three-node-cluster_installing-bare-metal). Setting `count_compute=0` will support deployment of a 3-node cluster. [↩](#openshift-via-terraform-on-equinix-metal)
