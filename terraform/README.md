![](https://img.shields.io/badge/stability-experimental-red.svg)

# OpenShift via Terraform on Packet
This collection of modules will deploy  will deploy a bare metal [OpenShift](https://docs.openshift.com/container-platform/latest/installing/installing_bare_metal/installing-bare-metal.html) consisting of (1) ephemeral bootstrap node, (3) control plane nodes, and a user-configured count of worker nodes<sup>[1](#3nodedeployment)</sup> on [Packet](http://packet.com). DNS records are automatically configured using [Cloudflare](http://cloudflare.com).

## Install Terraform
Terraform is just a single binary.  Visit their [download page](https://www.terraform.io/downloads.html), choose your operating system, make the binary executable, and move it into your path.

Here is an example for **macOS**:
```bash
curl -LO https://releases.hashicorp.com/terraform/0.12.25/terraform_0.12.26_darwin_amd64.zip
unzip terraform_0.12.25_darwin_amd64.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/
```
Example for **Linux**:
```bash
wget https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip
unzip terraform_0.12.26_linux_amd64.zip
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
git clone https://github.com/RedHatSI/openshift-packet-deploy.git
cd openshift-packet-deploy/terraform
```

## Usage

1. Follow [this](PACKET.md) to configure your Packet Public Cloud project and collect required parameters.

2. Follow [this](CLOUDFLARE.md) to configure your Cloudflare account and collect required parameters.

3. [Obtain an OpenShift Cluster Manager API Token](https://cloud.redhat.com/openshift/token) for pullSecret generation.
  
4. Configure TF_VARs applicable to your Packet project, Cloudflare zone, and OpenShift API Token:
     ```bash
     export TF_VAR_project_id="kajs886-l59-8488-19910kj"
     export TF_VAR_auth_token="lka6702KAmVAP8957Abny01051"
     
     export TF_VAR_cf_email="yourcfmail@domain.com"
     export TF_VAR_cf_api_key="21df29762169c002ca656"
     export TF_VAR_cf_zone_id="706767511sf7377900"

     export TF_VAR_cluster_basedomain="domain.com"
     export TF_VAR_ocp_cluster_manager_token="eyJhbGc...d8Agva"
     ```

5. Initialize and validate terraform:
     ```bash
     terraform init
     terraform validate
     ```

 6. Provision all resources and start the installation. This process takes between 30 and 50 minutes:
     ```bash
     terraform apply
     ``` 

 7. Cleanup the boostrap node once provisioning and installation is complete by permanently (recommended) or temporarily setting `count_bootstrap=0`
     ```bash
     terraform apply -var="count_bootstrap=0"
     ```
     If you need to obtain your `kubeadmin` credentials at a later time:
     ```
     terraform output
     ```

## Experimental Statement

This repository is [Experimental](https://github.com/packethost/standards/blob/master/experimental-statement.md)!


---

<a name="3nodedeployment"><sup>1</sup></a> As of OpenShift Container Platform 4.5 you can [deploy three-node clusters on bare metal](https://docs.openshift.com/container-platform/4.5/installing/installing_bare_metal/installing-bare-metal.html#installation-three-node-cluster_installing-bare-metal). Setting `count_compute=0` will support deployment of a 3-node cluster. [↩](#openshift-via-terraform-on-packet)