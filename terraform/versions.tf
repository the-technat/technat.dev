terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.13.9"
    }
    akeyless = {
      version = "~> 1.3.6"
      source  = "akeyless-community/akeyless"
    }
  }
}
