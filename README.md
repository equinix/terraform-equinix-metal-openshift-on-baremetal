[![Terraform CI](https://github.com/equinix/terraform-metal-openshift-on-baremetal/workflows/Terraform%20CI/badge.svg)](https://github.com/equinix/terraform-metal-openshift-on-baremetal/actions?query=workflow%3A%22Terraform+CI%22) [![](https://img.shields.io/badge/stability-experimental-red.svg)](#experimental-statatement)

# OpenShift via Terraform on Equinix Metal

This collection of modules will deploy will deploy a bare metal [OpenShift](https://docs.openshift.com/container-platform/latest/installing/installing_bare_metal/installing-bare-metal.html) consisting of (1) ephemeral bootstrap node, (3) control plane nodes, and a user-configured count of worker nodes<sup>[1](#3nodedeployment)</sup> on [Equinix Metal](https://metal.equinix.com). DNS records are automatically configured using [Cloudflare](http://cloudflare.com).

## Install Terraform

Terraform is just a single binary. Visit their [download page](https://www.terraform.io/downloads.html), choose your operating system, make the binary executable, and move it into your path.

Here is an example for **macOS**:

```bash
curl -LO https://releases.hashicorp.com/terraform/0.14.7/terraform_0.14.7_darwin_amd64.zip
unzip terraform_0.14.7_darwin_amd64.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/
```

Example for **Linux**:

```bash
wget https://releases.hashicorp.com/terraform/0.14.7/terraform_0.14.7_linux_amd64.zip
unzip terraform_0.14.7_linux_amd64.zip
sudo install terraform /usr/local/bin/
```

### Additional requirements

`local-exec` provisioners require the use of:

- `curl`
- `jq`

To install `jq` on **RHEL/CentOS**:

```bash
wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
sudo install jq-linux64 /usr/local/bin/jq
```

To install `jq` on **Debian/Ubuntu**:

```bash
sudo apt-get install jq
```

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

1. Configure TF_VARs applicable to your Equinix Metal project, Cloudflare zone, and OpenShift API Token:

    ```bash
    export TF_VAR_project_id="kajs886-l59-8488-19910kj"
    export TF_VAR_auth_token="lka6702KAmVAP8957Abny01051"

    export TF_VAR_cluster_basedomain="domain.com"
    export TF_VAR_ocp_cluster_manager_token="eyJhbGc...d8Agva"
    export TF_VAR_dns_provider = "cloudflare"
    export TF_VAR_dns_options = {"api_token": "abc..."}
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
