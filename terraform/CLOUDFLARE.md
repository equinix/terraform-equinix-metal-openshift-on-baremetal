# Cloudflare

This deployment automation uses the Cloudflare Managed DNS service.

1. Register domain name with any domain name registrar.

You can use any top-level domain (TLD) as com, org, net etc.

After the domain is registered, this domain’s **authoritative** name server records must be updated to point to Cloudflare nameservers as follows.

This domain name (in its "base domain" form) will be used later as a value for the `cluster_basedomain` variable in the Terraform configuration.

```
Example of the cluster_basedomain value: "domain.com"
```

2. Create Cloudflare account

Go to https://dash.cloudflare.com/sign-up and create the account.

3. Add the previously register domain (called "site" in the Cloudflare interface) to the newly created Cloudflare account.
 
4.	Update this domain’s **authoritative** name server records at the **registrar web site** to point to Cloudflare nameservers.


See [this](https://support.cloudflare.com/hc/en-us/articles/205195708-Changing-your-domain-nameservers-to-Cloudflare) help page “Changing your domain nameservers to Cloudflare” for guidance.

At this step you must wait until [ICANN WHOIS](https://whois.icann.org/) points to the Cloudflare nameservers.

Read [this](https://support.cloudflare.com/hc/en-us/articles/360042815891-Understanding-domain-status) help page “Understanding domain status”.

When this step is complete, your domain’s DNS page at Cloudflare should have the Cloudflare nameservers listed.
 
5.	Copy the zone ID

On your domain’s landing page at Cloudflare, navigate to the “Overview” page.
 
Scroll down, and locate the “Zone ID” value, copy it, it will be used later as a value for the `cf_zone_id` parameter in the Terraform configuration.

```
Example of the cf_zone_id parameter value: "932167c5c19151a905da5cd1e591245c"
```

 
6.	Copy the API key

On the same page as above click on the “Get your API token” link.
 
You will be presented with the “API Token” tab from the “My Profile” page, click the “View” button at the “Global API key”.
 
Save this key value, it will be used later as value of the `cf_api_key` in the Terraform configuration.

```
Example of the cf_api_key parameter value: "65ca543659011ba2a13b2ab06dab12c158bcb"
```

7.	Copy email address

On the page above, change to the “Communication” page and save the “Email Address” value, it will be used later as value of the `cf_email` in the Terraform configuration.
 
```
Example of the cf_email parameter value: "me@mywork.org"
```

[Top](README.md)
