# OpenShift via Terraform on Packet
This collection of modules will deploy  will deploy a bare metal [OpenShift](https://docs.openshift.com/container-platform/latest/installing/installing_bare_metal/installing-bare-metal.html) consisting of (1) ephemeral bootstrap node, (3) control plane nodes, and a user-configured count of worker nodes on [Packet](http://packet.com). DNS records are automatically configured using Cloudflare.

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

`local-exec` provisioners require the use of:
  - `curl`
  - `jq`

## Download this project
To download this project, run the following command:

```bash
git clone https://github.com/RedHatSI/openshift-packet-deploy.git
cd openshift-packet-deploy/terraform
```

## Initialize Terraform
Terraform uses modules to deploy infrastructure. In order to initialize the modules your simply run: `terraform init`. This should download modules into a hidden directory `.terraform`


## Usage

  1. Configure an API token for your account/project
  2. Configure TF_VARs applicable to your Packet project using 
     ```bash
     export TF_VAR_project_id="kajs886-l59-8488-19910kj"
     export TF_VAR_project_name="automated-openshift-work"
     export TF_VAR_auth_token="lka6702KAmVAP8957Abny01051"

     export TF_VAR_cf_email="yourcfmail@domain.com"
     export TF_VAR_cf_api_key="21df29762169c002ca656"
     export TF_VAR_cf_acct_id="cdafa76r7574576565658ae"
     export TF_VAR_cf_zone_id="706767511sf7377900"
     ```

  3. Initialize and validate terraform
     ```bash
     terraform init
     terraform validate
     ```

  5. Apply the remaining resources:
     ```bash
     terraform apply
     ``` 

  6. Cleanup the boostrap node once provisioning and installation is complete
     ```bash
     terraform destroy --target=module.bootstrap_openshift.packet_device.bootstrap[0]
     ```
