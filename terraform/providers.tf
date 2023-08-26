provider "openstack" {
  application_credential_secret = var.openstack_token
  application_credential_id     = "4e7a622b013b49f7875628b3a8d2543d" # generated within the console & unrestricted
  auth_url                      = "https://api.pub1.infomaniak.cloud/identity"
  region                        = "dc3-a"
}

provider "tailscale" {
  api_key = var.tailscale_api_key # expires every 90 days
  tailnet = "the-technat.github"  # created by sign-up via Github
}

provider "akeyless" {
  api_gateway_address = "https://api.akeyless.io"
  api_key_login { # associated with the admin role
    access_id  = "p-zzvst51rfc6q"
    access_key = var.akeyless_access_key
  }
}
