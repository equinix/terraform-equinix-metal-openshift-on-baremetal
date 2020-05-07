# Usage

  1. Configure an API token for your account/project
  2. Configure TF_VARs applicable to your Packet project
     ```
     export TF_VAR_project_id="kajs886-l59-8488-19910kj"
     export TF_VAR_project_name="automated-openshift-work"
     export TF_VAR_auth_token="lka6702KAmVAP8957Abny01051"

     export TF_VAR_cf_email="yourcfmail@domain.com"
     export TF_VAR_cf_api_key="21df29762169c002ca656"
     export TF_VAR_cf_acct_id="cdafa76r7574576565658ae"
     export TF_VAR_cf_zone_id="706767511sf7377900"
     ```
  3. Initialize and validate terraform
     ```
     terraform init
     terraform validate
     terraform plan
     terraform apply
     ```

