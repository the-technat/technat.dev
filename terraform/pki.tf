resource "akeyless_dfc_key" "primary" {
  alg               = "RSA4096"
  name              = "axiom/ca/primary"
  delete_protection = true
  description       = "Primary Key for Axiom CA"
}
