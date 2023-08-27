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

### Tailscale networking
resource "tailscale_acl" "global" {
  acl = jsonencode({
    acls : [
			# internet is always open for everyone (also via exitNodes)
			{
				"action": "accept",
				"src": [
					"*"
				],
				"dst": [
					"autogroup:internet:*"
				]
			},
			# k3s can communicate with itself anyways
			{
				"action": "accept",
				"src": [
					"tag:k3s"
				],
				"dst": [
					"tag:k3s:*"
				]
			},
			# only this tag can access other nodes
			{
				"action": "accept",
				"src": [
					"tag:trusted"
				],
				"dst": [
					"*:*"
				]
			},
    ],
  })
}
