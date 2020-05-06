# Usage

  1. Configure an API token for your account/project
  2. Configure TF_VARs applicable to your Packet project
     ```
     export TF_VAR_project_id="kajs886-l59-8488-19910kj"
     export TF_VAR_project_name="automated-openshift-work"
     export TF_VAR_auth_token="lka6702KAmVAP8957Abny01051"
     ```
  3. Initialize and validate terraform
     ```
     terraform init
     terraform validate
     terraform plan
     terraform apply
     ```

