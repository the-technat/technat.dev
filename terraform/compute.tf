### Common things 
locals {
  image_id = "a103ffce-9165-42d7-9c1f-ba0fe774fac5" # Ubuntu 22.04 LTS Jammy Jellyfish
  ssh_user = "terraform"
  cloud_init_file = templatefile("${path.module}/templates/cloud_init.tmpl", {
    ssh_user        = local.ssh_user
    device_auth_key = tailscale_tailnet_key.bootstrap.key
    ssh_keys        = [openstack_compute_keypair_v2.terraform.public_key, openstack_compute_keypair_v2.yubikey.public_key]
  })
}

resource "openstack_compute_keypair_v2" "yubikey" {
  name       = "yubikey"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJov21J2pGxwKIhTNPHjEkDy90U8VJBMiAodc2svmnFC cardno:000618187880"
}

# used by the k3s terraform module
resource "openstack_compute_keypair_v2" "terraform" {
  name = "terraform"
}

resource "tailscale_tailnet_key" "bootstrap" {
  ephemeral     = false
  reusable      = true
  preauthorized = true
  # expiry        = 300 # 5min
  expiry = 3600
  tags   = ["tag:k3s"]

  # lifecycle {
  # https://github.com/tailscale/terraform-provider-tailscale/issues/144
  # }
}

### M-O-1 (first control-plane node)
resource "openstack_compute_instance_v2" "m-o-1" {
  name                = "m-o-1"
  image_id            = local.image_id
  flavor_name         = "a1-ram2-disk20-perf1"
  admin_pass          = data.akeyless_static_secret.m-o-1_password.value
  security_groups     = [openstack_compute_secgroup_v2.axiom_default.name]
  user_data           = local.cloud_init_file
  stop_before_destroy = true

  network {
    name = "axiom"
  }

  lifecycle {
    prevent_destroy = true
  }
}

data "akeyless_static_secret" "m-o-1_password" {
  path = "axiom/infrastrucutre/m-o-1"
}
