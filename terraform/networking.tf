resource "openstack_dns_zone_v2" "axiom" {
  name        = "axiom.technat.ch."
  email       = "technat@technat.ch"
  description = "Axiom internal DNS zone"
  ttl         = 3000
  type        = "PRIMARY"
}
