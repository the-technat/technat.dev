### Openstack Networking
locals {
  # this network will give you a static public IP in infomaniak's network blocks
  infomaniak_public_net = "0f9c3806-bd21-490f-918d-4a6d1c648489" # ext-floating1 
}
resource "openstack_networking_network_v2" "axiom" {
  name           = "axiom"
  admin_state_up = "true"
}

resource "openstack_networking_router_v2" "primary" {
  name                = "primary"
  external_network_id = local.infomaniak_public_net
}

resource "openstack_networking_subnet_v2" "axiom" {
  name        = "a"
  description = "no meaningful name, but a subnet is currently not bound to an AZ or so"
  network_id  = openstack_networking_network_v2.axiom.id
  cidr        = "192.168.111.0/24"
  ip_version  = 4

  # ns1.pub1.infomaniak.cloud && ns2.pub1.infomaniak.cloud
  # dns_nameservers = ["185.125.25.123", "185.125.25.119"]

  dns_nameservers = ["149.112.112.112", "9.9.9.9"]
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.primary.id
  subnet_id = openstack_networking_subnet_v2.axiom.id
}

resource "openstack_compute_secgroup_v2" "axiom_default" {
  name        = "axiom_default"
  description = "default axiom security group"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

### Tailscale networking
# resource "tailscale_acl" "global" {
#   acl = jsonencode({
#     acls : [
#       # internet is always open for everyone (also via exitNodes)
#       {
#         "action" : "accept",
#         "src" : [
#           "*"
#         ],
#         "dst" : [
#           "autogroup:internet:*"
#         ]
#       },
#       # k3s can communicate with itself anyways
#       {
#         "action" : "accept",
#         "src" : [
#           "tag:k3s"
#         ],
#         "dst" : [
#           "tag:k3s:*"
#         ]
#       },
#       # only this tag can access other nodes
#       {
#         "action" : "accept",
#         "src" : [
#           "tag:trusted"
#         ],
#         "dst" : [
#           "*:*"
#         ]
#       },
#     ],
#   })
# unfortunately Terraform currently doesn't support the entire ACL file
# 	"tagOwners": {
#   "tag:exitNode": [
#     "autogroup:members",
#   ],
#   "tag:funnel": [
#     "autogroup:members",
#   ],
#   "tag:trusted": [
#     "autogroup:members",
#   ],
#   "tag:k3s": [
#     "autogroup:members",
#   ],
# },
# "autoApprovers": {
#   // automatically accepts the advertise-exit-node flag from nodes taged like that
#   "exitNode": [
#     "tag:exitNode"
#   ],
#   // k3s can automatically adervise routes in these CIDRs
#   "routes": {
#     "10.227.0.0/16": [
#       "tag:k3s"
#     ],
#     "10.127.0.0/16": [
#       "tag:k3s"
#     ],
#   },
# },
# "nodeAttrs": [
#   // activates the funnel feature on nodes with that tag
#   {
#     "target": [
#       "tag:funnel"
#     ],
#     "attr": [
#       "funnel"
#     ],
#   },
# ],
# "acls": [
#   // internet is always open for everyone (also via exitNodes)
#   {
#     "action": "accept",
#     "src": [
#       "*"
#     ],
#     "dst": [
#       "autogroup:internet:*"
#     ]
#   },
#   // k3s can communicate with itself anyways
#   {
#     "action": "accept",
#     "src": [
#       "tag:k3s"
#     ],
#     "dst": [
#       "tag:k3s:*"
#     ]
#   },
#   // only this tag can access other nodes
#   {
#     "action": "accept",
#     "src": [
#       "tag:trusted"
#     ],
#     "dst": [
#       "*:*"
#     ]
#   },
# ],
# "ssh": [
#   {
#     "action": "accept",
#     "src": [
#       "tag:trusted"
#     ], // only trusted devices can ssh into other nodes
#     "dst": [
#       "tag:trusted"
#     ],
#     "users": [
#       "autogroup:nonroot",
#       "root"
#     ],
#   },
#   {
#     "action": "accept",
#     "src": [
#       "tag:trusted"
#     ], // only trusted devices can ssh into other nodes
#     "dst": [
#       "tag:k3s"
#     ],
#     "users": [
#       "autogroup:nonroot",
#       "root"
#     ],
#   },
#   {
#     "action": "accept",
#     "src": [
#       "tag:trusted"
#     ], // only trusted devices can ssh into other nodes
#     "dst": [
#       "tag:exitNode"
#     ],
#     "users": [
#       "autogroup:nonroot",
#       "root"
#     ],
#   },
# ],
# }
# }
