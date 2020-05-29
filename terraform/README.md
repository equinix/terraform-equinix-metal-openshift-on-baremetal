
# OpenShift via Terraform on Packet
This collection of modules will deploy  will deploy a bare metal [OpenShift](https://docs.openshift.com/container-platform/latest/installing/installing_bare_metal/installing-bare-metal.html) consisting of (1) ephemeral bootstrap node, (3) control plane nodes, and a user-configured count of worker nodes on [Packet](http://packet.com). DNS records are automatically configured using [Cloudflare](http://cloudflare.com).

## Install Terraform
Terraform is just a single binary.  Visit their [download page](https://www.terraform.io/downloads.html), choose your operating system, make the binary executable, and move it into your path.

Here is an example for **macOS**:
```bash
curl -LO https://releases.hashicorp.com/terraform/0.12.25/terraform_0.12.25_darwin_amd64.zip
unzip terraform_0.12.25_darwin_amd64.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/
```
### Additional requirements

Currently the execution environment is [limited to Linux](https://github.com/RedHatSI/openshift-packet-deploy/issues/17). `local-exec` provisioners require the use of:
  - `curl`
  - `jq`

## Download this project
To download this project, run the following command:

```bash
git clone https://github.com/RedHatSI/openshift-packet-deploy.git
cd openshift-packet-deploy/terraform
```

## Usage

  1. Configure and obtain an [API token for your Packet account/project](https://www.packet.com/developers/api/) and [Cloudflare API token & zone ID details](https://dash.cloudflare.com/)
  2. Obtain an OpenShift Cluster Manager API Token for pullSecret generation
  
  2. Configure TF_VARs applicable to your Packet project, Cloudflare zone, and OpenShift API Token:
     ```bash
     export TF_VAR_project_id="kajs886-l59-8488-19910kj"
     export TF_VAR_auth_token="lka6702KAmVAP8957Abny01051"
     
     export TF_VAR_cf_email="yourcfmail@domain.com"
     export TF_VAR_cf_api_key="21df29762169c002ca656"
     export TF_VAR_cf_zone_id="706767511sf7377900"

     export TF_VAR_cluster_basedomain="domain.com"
     export TF_VAR_ocp_cluster_manager_token="eyJhbGc...d8Agva"
     ```

     2.1. Check to ensure you have an ssh key-pair located at ***~/.ssh/id_rsa*** and ***~/.ssh/id_rsa.pub*** respectively. If not you need to update both ***ssh_public_key_path*** and ***ssh_private_key_path***.

  3. Initialize and validate terraform:
     ```bash
     terraform init
     terraform validate
     ```

  5. Provision all resources and start the installation. This process takes between 30 and 50 minutes:
     ```bash
     terraform apply
     ``` 

  6. Cleanup the boostrap node once provisioning and installation is complete
     ```bash
     terraform destroy --target=module.bootstrap_openshift.packet_device.bootstrap[0]
     ```

