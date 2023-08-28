resource "openstack_dns_zone_v2" "axiom" {
  # Note: NS servers have to be manually added to the correct location for the zone to work
  name        = "axiom.technat.ch."
  email       = "technat@technat.ch"
  description = "Axiom internal DNS zone"
  ttl         = 3000
  type        = "PRIMARY"
}

resource "tailscale_dns_nameservers" "tailnet" {
  nameservers = [
    "76.76.2.38",
    "76.76.10.38",
    "2606:1a40::38",
    "2606:1a40:1::38",
  ]
}

resource "tailscale_dns_preferences" "global" {
  magic_dns = true
}

## Currently missing an option to set the DNS domain for your tailnet
locals {
  tailnet_domain = "crocodile-bee.ts.net"
}
