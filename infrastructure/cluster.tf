module "tempest" {
  source = "git::https://github.com/poseidon/typhoon//aws/flatcar-linux/kubernetes?ref=v1.30.3"

  # AWS
  cluster_name = "try"
  dns_zone     = "aws.technat.dev"
  dns_zone_id = "Z05515632389XR2PUYQ8O"

  # instances
  worker_count = 2
  worker_type  = "t3.small"

  # configuration
  ssh_authorized_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4gIw+m6IO73vnF9NKGkvQFq+dFqSprAepSD1MCjEjC Typhoon"
}

resource "local_file" "kubeconfig" {
  content  = module.tempest.kubeconfig-admin
  filename = "${path.module}/kubeconfig"
}