### DNS
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

### Openstack Networking
resource "openstack_networking_network_v2" "axiom" {
  name           = "axiom"
  admin_state_up = "true"
}

resource "openstack_networking_router_v2" "primary" {
  name                = "primary"
  external_network_id = "0f9c3806-bd21-490f-918d-4a6d1c648489" # ext-floating1
}

resource "openstack_networking_subnet_v2" "axiom" {
  network_id = openstack_networking_network_v2.axiom.id
  cidr       = "192.168.111.0/24"
  ip_version = 4
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.primary.id
  subnet_id = openstack_networking_subnet_v2.axiom.id
}
