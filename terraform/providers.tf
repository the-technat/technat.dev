provider "openstack" {
  application_credential_secret = var.openstack_token
  application_credential_id     = "4e7a622b013b49f7875628b3a8d2543d"
  auth_url                      = "https://api.pub1.infomaniak.cloud/identity"
  region                        = "dc3-a"
}
