############
# Variables
############
variable "hcloud_token" {
    type = string
    sensitive = true
}
variable "tailscale_api_key" {
    type = string
    sensitive = true
}
variable "tailnet" {
    type = string
}

locals {
  tailnet_domain  = "little-cloud.ts.net"
}
############
# Resources
############
resource "hcloud_ssh_key" "yubikey" {
  name       = "Yubikey"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJov21J2pGxwKIhTNPHjEkDy90U8VJBMiAodc2svmnFC"
}

resource "hcloud_ssh_key" "terraform" {
  name = "terraform"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA84isPE5YcaUslfcaxkkMHFEvPh5pwwNcD/HUHfTEzw tevbox terraform"
}

resource "hcloud_server" "minion_1" {
  name        = "minion-1"
  image       = "ubuntu-22.04"
  server_type = "cpx21"
  location    = "hel1"
  keep_disk   = true
  ssh_keys    = [hcloud_ssh_key.yubikey.id, hcloud_ssh_key.terraform.id]
  public_net {
    ipv4_enabled = true # as soon as github.com supports ipv6, this is theoretically not needed any more
    ipv6_enabled = true
  }
  user_data = <<EOT
    #cloud-config minion-1
    packages:
    - python3
    - python3-pip
    - git
    - jq
    runcmd:
      - |
        curl -fsSL https://tailscale.com/install.sh | sh
        # We want to make sure any Tailscale devices with this name have been deleted.
        curl 'https://api.tailscale.com/api/v2/tailnet/${var.tailnet}/devices' -u "${var.tailscale_api_key}:" |  \
        jq -r '.devices[] | select(.hostname == "minion-1") | .nodeId' |  while read -r nodeid
        do
           curl -X DELETE "https://api.tailscale.com/api/v2/device/$nodeid" -u "${var.tailscale_api_key}:" -v
        done
        sudo tailscale up --ssh --auth-key ${tailscale_tailnet_key.bootstrap.key}

        pip3 install ansible
        ansible-galaxy collection install community.galaxy
  EOT
}

resource "hcloud_server" "minion_2" {
  name        = "minion-2"
  image       = "ubuntu-22.04"
  server_type = "cpx21"
  location    = "hel1"
  keep_disk   = true
  ssh_keys    = [hcloud_ssh_key.yubikey.id]
  public_net {
    ipv4_enabled = true # as soon as github.com supports ipv6, this is theoretically not needed any more
    ipv6_enabled = true
  }
  user_data = <<EOT
    #cloud-config minion-2
    packages:
    - python3
    - python3-pip
    - git
    runcmd:
      - |
        curl -fsSL https://tailscale.com/install.sh | sh
        # We want to make sure any Tailscale devices with this name have been deleted.
        curl 'https://api.tailscale.com/api/v2/tailnet/${var.tailnet}/devices' -u "${var.tailscale_api_key}:" |  \
        jq -r '.devices[] | select(.hostname == "minion-2") | .nodeId' |  while read -r nodeid
        do
           curl -X DELETE "https://api.tailscale.com/api/v2/device/$nodeid" -u "${var.tailscale_api_key}:" -v
        done
        sudo tailscale up --ssh --auth-key ${tailscale_tailnet_key.bootstrap.key}

        pip3 install ansible
        ansible-galaxy collection install community.galaxy
  EOT
}

resource "hcloud_server" "minion_3" {
  name        = "minion-3"
  image       = "ubuntu-22.04"
  server_type = "cpx21"
  location    = "hel1"
  keep_disk   = true
  ssh_keys    = [hcloud_ssh_key.yubikey.id]
  public_net {
    ipv4_enabled = true # as soon as github.com supports ipv6, this is theoretically not needed any more
    ipv6_enabled = true
  }
  user_data = <<EOT
    #cloud-config minion-3
    packages:
    - python3
    - python3-pip
    - git
    runcmd:
      - |
        curl -fsSL https://tailscale.com/install.sh | sh
        # We want to make sure any Tailscale devices with this name have been deleted.
        curl 'https://api.tailscale.com/api/v2/tailnet/${var.tailnet}/devices' -u "${var.tailscale_api_key}:" |  \
        jq -r '.devices[] | select(.hostname == "minion-3") | .nodeId' |  while read -r nodeid
        do
           curl -X DELETE "https://api.tailscale.com/api/v2/device/$nodeid" -u "${var.tailscale_api_key}:" -v
        done
        sudo tailscale up --ssh --auth-key ${tailscale_tailnet_key.bootstrap.key}

        pip3 install ansible
        ansible-galaxy collection install community.galaxy
  EOT
}

resource "tailscale_tailnet_key" "bootstrap" {
  ephemeral     = false
  reusable      = true
  preauthorized = true
  expiry        = 900 # 15min
  tags          = ["tag:funnel", "tag:lan"]
}

############
# Data Sources
############
data "tailscale_device" "minion_1" {
  name     = "minion-1.${local.tailnet_domain}"
  wait_for = "300s"

  depends_on = [hcloud_server.minion_1]
}

data "tailscale_device" "minion_2" {
  name     = "minion-2.${local.tailnet_domain}"
  wait_for = "300s"

  depends_on = [hcloud_server.minion_2]
}

data "tailscale_device" "minion_3" {
  name     = "minion-3.${local.tailnet_domain}"
  wait_for = "300s"

  depends_on = [hcloud_server.minion_3]
}

############
# Providers & requirements
############
provider "hcloud" {
  token = var.hcloud_token
}

provider "tailscale" {
  api_key = var.tailscale_api_key # expires every 90 days
  tailnet = var.tailnet         # created by sign-up via Github
}

terraform {
  required_version = ">= 1.5.5"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.42.1"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.13.9"
    }
  }
}