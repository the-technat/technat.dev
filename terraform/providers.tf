provider "openstack" {
  application_credential_secret = var.openstack_token
  application_credential_id     = var.openstack_user # generated within the console & unrestricted
  auth_url                      = "https://api.pub1.infomaniak.cloud/identity"
  region                        = "dc3-a"
}

provider "tailscale" {
  api_key = var.tailscale_api_key # expires every 90 days
  tailnet = var.tailscale_tailnet # created by sign-up via Github
}

provider "akeyless" {
  api_gateway_address = "https://api.akeyless.io"
  api_key_login { # associated with the admin role
    access_id  = var.akeyless_access_id
    access_key = var.akeyless_access_key
  }
}
