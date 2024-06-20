# 02 Cluster Initialization

## Init config

This is my init config based on the [Kubeadm config reference](https://kubernetes.io/docs/reference/config-api/kubeadm-config.v1beta3/#kubeadm-k8s-io-v1beta3-JoinConfiguration):

```yaml
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
skipPhases:
  - addon/kube-proxy
---
apiVersion: kubeadm.k8s.io/v1beta3
clusterName: banana
kind: ClusterConfiguration
kubernetesVersion: 1.26.1
networking:
  dnsDomain: banana.k8s
  serviceSubnet: 10.111.0.0/16
  podSubnet: 10.222.0.0/16
controlPlaneEndpoint: api.alleaffengaffen.ch:6443
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd 
```

Some notes:

- kubelet must be told to use systemd's cgroup driver
- the `controlPlaneEndpoint` is a DNS entry to allow for futher horizontal scaling of control-plane
- the `podSubnet` and `serviceSubnet` don´t have to be specified because we skip kube-proxy and cilium does it's own IPAM, other CNIs could require them to be set correctly
- the `dnsDomain` is just pure cosmetic since youĺl probably never resolve anything within K8S using it's FQDN.

Init the cluster using this config:

```bash
sudo kubeadm init --config config.yaml 
```

## Graceful node shutdown

Sometimes a node needs to be restarted. To ensure all containers are stopped gracefully in such a case, configure the kubelet accordingly to this [guide](https://kubernetes.io/docs/concepts/architecture/nodes/#graceful-node-shutdown). The fields are already present in `/var/lib/kubelet/config.yaml` so just change them to `30s`, respectively `20s` for critical pods.

## Worker nodes

Join them using the printed join command or if the token expired, create a new join command using:

```bash
kubeadm token create --print-join-command
```

## Next Step

- > [03 Core Addons](./03_core_addons.md)
