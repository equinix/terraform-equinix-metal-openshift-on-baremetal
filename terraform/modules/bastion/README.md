
# Nginx via Terraform on Packet
This is a very basic [Terraform](http://terraform.io) template that will deploy [Nginx](http://nginx.org) on [Packet](http://packet.com) baremetal.
## Install Terraform 
Terraform is just a single binary.  Visit their [download page](https://www.terraform.io/downloads.html), choose your operating system, make the binary executable, and move it into your path. 
 
Here is an example for **macOS**: 
```bash 
curl -LO https://releases.hashicorp.com/terraform/0.12.25/terraform_0.12.25_darwin_amd64.zip 
unzip terraform_0.12.25_darwin_amd64.zip
chmod +x terraform 
sudo mv terraform /usr/local/bin/ 
``` 
 
## Download this project
To download this project, run the following command:

```bash
git clone https://github.com/c0dyhi11/packet-nginx.git
cd packet-nginx
```

## Initialize Terraform 
Terraform uses modules to deploy infrastructure. In order to initialize the modules your simply run: `terraform init`. This should download modules into a hidden directory `.terraform` 
 
## Modify your variables 
You will need to set three variables at a minimum and there are a lot more you may wish to modify in `variables.tf`
```bash 
cat <<EOF >terraform.tfvars 
auth_token = "cefa5c94e8ee4577bff81d1edca93ed8" 
project_id = "42259e34-d300-48b3-b3e1-d5165cd14169" 
EOF 
``` 

## Deploy Terraform template
```bash
terraform apply --auto-approve
```
Once this is complete you should get output similar to this:
```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

nginx_ip = 139.178.89.181
```

## Variables
| Variable Name | Type | Default Value | Description |
| :-----------: |:---: | :------------:|:------------|
| auth_token | string | n/a | Packet API Key |
| project_id | string | n/a | Packet Project ID |
| facility | string | sjc1 | Packet  Facility  to  deploy  into |
| plan | string | c3.medium.x86 | Packet  device  type  to  deploy |
| operating_system | string | centos_8 | The  Operating  system  of  the  node |
| billing_cycle | string | hourly | How  the  node  will  be  billed (Not  usually  changed) |

Enjoy!
