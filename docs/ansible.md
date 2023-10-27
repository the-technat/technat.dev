# Ansible

## Inventory

The inventory script I'm using fetches all devices from my tailnet and groups them by tags. This means that my Tailscale ACL tags are not only for ACLs itself but also represent groups for ansible. An appropriate naming convnetion for tags has been created.

Ansible thus relies on some ACL tags starting with "tag_info_" to install the right thing on the right nodes.

## Playbooks

### Cluster deployment

Prepares the nodes for k3s, installs k3s and makes sure the cluster is up & running (including the minimal CNI config).

Important to mention:
- ARM/ARM64/AMD64 supported
- Debian, Ubuntu, RHEL and CentOs supported
- using the install-script from get.k3s.io to setup k3s
  - to configure we paste all options into the newly introduce config file (thus a change in the file + restart of the service applies new stuff)
- uses the fixed hostname `m-o-1` as the node to init the cluster with (this because we have a naming concept)

The HA thing would be done using tls-san + multiple DNS records

Most important for k3s to run over tailscale: `--node-ip=100.100.123.123`. This makes sure k3s, cilium and all other systems communicate over tailscale

### Cluster upgraded

Upgrades k3s to new minor or patch versions and optionally updates the OS of the nodes. Can be run using a cron syntax to periodically update everything. (Or we could use kured/system-upgraded-controller for this).

