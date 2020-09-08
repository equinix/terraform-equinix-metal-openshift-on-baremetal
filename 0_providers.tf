provider "packet" {
  auth_token = var.auth_token
}


provider "cloudflare" {
  email   = var.cf_email
  api_key = var.cf_api_key
}

