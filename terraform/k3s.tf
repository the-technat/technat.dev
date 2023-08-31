resource "null_resource" "tailscale_join" {

  provisioner "local_exec" {
    command = "curl -fsSL https://tailscale.com/install.sh | sh && tailscale up --auth-key ${tailscale_tailnet_key.tfc.value}"
  }
}
resource "tailscale_tailnet_key" "tfc" {
  ephemeral     = true
  reusable      = true
  preauthorized = true
  expiry        = 300 # 5min
  tags          = ["tag:k3s"]

  # https://github.com/tailscale/terraform-provider-tailscale/issues/144
  lifecycle {
    replace_triggered_by = [time_rotating.tskey]
  }
}

module "k3s" {
  source         = "xunleii/k3s/module"
  version        = "v3.3.0"
  k3s_version    = "stable"
  cluster_domain = "axiom.technat.ch"
  cidr = {
    pods     = "10.111.0.0/16"
    services = "10.222.0.0/16"
  }
  drain_timeout  = "300s"
  managed_fields = ["label", "taint"]
  global_flags = [
    "--tls-san api.axiom.technat.ch"
  ]
  servers = {
    m-o-1 = {
      ip = data.tailscale_device.m-o-1.ip
      connection = {
        host = data.tailscale_device.m-o-1.ip
        user = local.ssh_user
      }
      flags  = ["--flannel-backend=none"]
      labels = { "node.kubernetes.io/type" = "master" }
      taints = { "node.k3s.io/type" = "server:NoSchedule" }
    }
  }
  agents = {}
}
