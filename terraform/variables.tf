variable "openstack_token" {
  type      = string
  sensitive = true
}

variable "openstack_user" {
  type = string
}

variable "tailscale_api_key" {
  type      = string
  sensitive = true
}

variable "akeyless_access_key" {
  type      = string
  sensitive = true
}

variable "akeyless_access_id" {
  type = string
}

variable "tailscale_tailnet" {
  type = string
}
