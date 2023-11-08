# K3S

## Thoughts

We are using the official install script to provision our nodes. It's the easiest and most bulletproof method I can think of + it installs all the required dependencies itself.

## First Control-Plane node

The first control-plane node must init the cluster, thus it's a bit special:


``` 
curl -sfL https://get.k3s.io | sh -s - \
--cluster-init \
--node-ip $(tailscale ip -4) \
--node-external-ip 195.15.252.166 \
--tls-san=api.axiom.technat.ch \
--disable=traefik \
--disable-kube-proxy \
--disable-network-policy \
--flannel-backend none \
--secrets-encryption  \
--servicelb-namespace=servicelb
```

Don't forget to add the tailscale IP of the node to the DNS record.

### CNI Initialization

Before we can continue with other nodes, we need to initalize the CNI. For this I have a minimal Cilium helm values file in this directory, that can be used to get the cluster working. Later on Cilium is managed by Argo CD and thus is self-managed.

To get Cilium up & running:

```
helm repo add cilium https://helm.cilium.io
helm upgrade -i cilium -n kube-system cilium/cilium -f values/inital-cilium-values.yaml
```

## Additional Control-Plane nodes

If there are additional control-plane nodes, join them like so:

```
curl -sfL https://get.k3s.io | sh -s - server \ 
--server https://api.axiom.technat.ch:6443 \
--token </var/lib/rancher/k3s/server/token> \
--node-ip $(tailscale ip -4) \
--node-external-ip <public_ip_otherwise_remove> \
--tls-san=api.axiom.technat.ch \
--disable=traefik \
--disable-kube-proxy \
--disable-network-policy \
--flannel-backend none \
--secrets-encryption  \
--servicelb-namespace=servicelb
```

## Worker Nodes

Finally one can join worker nodes:

```
curl -sfL https://get.k3s.io | sh -s - agent \ 
--server https://api.axiom.technat.ch:6443 \
--token </var/lib/rancher/k3s/server/agent-token> \
--node-ip $(tailscale ip -4) \
--node-external-ip <public_ip_otherwise_remove> 
```