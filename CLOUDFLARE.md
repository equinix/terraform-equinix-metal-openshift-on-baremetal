# Cloudflare

This deployment automation uses the Cloudflare Managed DNS service.

1. Register domain name with any domain name registrar.

   You can use any top-level domain (TLD) as com, org, net etc.

   After the domain is registered, this domain’s **authoritative** name server records must be updated to point to Cloudflare nameservers as follows.

   This domain name (in its "base domain" form) will be used later as a value for the `cluster_basedomain` variable in the Terraform configuration.

   ```console
   Example of the cluster_basedomain value: "example.com"
   ```

1. Create Cloudflare account

   Go to <https://dash.cloudflare.com/sign-up> and create the account.

1. Add the previously register domain (called "site" in the Cloudflare interface) to the newly created Cloudflare account.

1. Update this domain’s **authoritative** name server records at the **registrar web site** to point to Cloudflare nameservers.

   See [this](https://support.cloudflare.com/hc/en-us/articles/205195708-Changing-your-domain-nameservers-to-Cloudflare) help page “Changing your domain nameservers to Cloudflare” for guidance.

   At this step you must wait until [ICANN WHOIS](https://whois.icann.org/) points to the Cloudflare nameservers.

   Read [this](https://support.cloudflare.com/hc/en-us/articles/360042815891-Understanding-domain-status) help page “Understanding domain status”.

   When this step is complete, your domain’s DNS page at Cloudflare should have the Cloudflare nameservers listed.

1. Copy the API key

   Follow the directions on <https://developers.cloudflare.com/fundamentals/api/get-started/create-token/> to create an API Token for use with this zone.

   Save this key value. You will use it in your Terraform environment by defining it as `CLOUDFLARE_API_TOKEN` in the environment.

   ```console
   Example of the cf_api_token parameter value: "65ca543659011ba2a13b2ab06dab12c158bcb"
   ```

[Top](README.md)
