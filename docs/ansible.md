# Ansible

## Inventory

The inventory script I'm using fetches all devices from my tailnet and groups them by tags. This means that my Tailscale ACL tags are not only for ACLs itself but also represent hints for ansible. An appropriate naming convnetion for tags has been created.

So ansible in workflows acts either on "tag:axiom" or "tag:control_plane" or "tag:compute_plane".

## Playbooks

### Cluster deployment

Prepares the nodes for k3s, installs k3s and makes sure the cluster is up & running (including the CNI).

Current challenge: how to determine the first server node, since he needs the `--cluster-init` flag and the others don't. In addition, the other server nodes must register themself by the first one, so they need the URL of the API of the first one.

The HA thing would be done using tls-san + multiple DNS records

Most important for k3s to run over tailscale: `--node-ip=100.100.123.123`. This makes sure k3s, cilium and all other systems communicate over tailscale

The cilium host firewall can later be used to secure traffic. 

### Cluster upgraded

Upgrades k3s to new minor or patch versions and optionally updates the OS of the nodes. Can be run using a cron syntax to periodically update everything. (Or we could use kured/system-upgraded-controller for this).

