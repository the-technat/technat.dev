locals {
  pki_tags = ["axiom"]

}

resource "akeyless_dfc_key" "primary" {
  alg               = "RSA4096"
  name              = "axiom/ca/primary"
  delete_protection = true
  description       = "Primary Key for Axiom CA"
  tags              = local.pki_tags
}

resource "akeyless_pki_cert_issuer" "primary" {
  name              = "axiom/ca/primary_ca"
  description       = "Root CA for axiom"
  signer_key_name   = "/axiom/ca/primary"
  ttl               = 2592000 # 30 days
  delete_protection = true

  allow_any_name   = true
  allow_subdomains = true
  country          = "Switzerland"
  province         = "Bern"
  organizations    = "the-technat"

  tags = local.pki_tags
}
