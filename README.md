# technat.dev

## Draft

Docs:
- https://syself.com/docs/caph/getting-started/introduction
- https://cluster-api.sigs.k8s.io


Get your temporary management cluster:

```console
kind create cluster --name caph-mgt-cluster
helm repo add jetstack https://charts.jetstack.io --force-update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set crds.enabled=true
helm repo add capi-operator https://kubernetes-sigs.github.io/cluster-api-operator
helm install capi-operator capi-operator/cluster-api-operator --create-namespace -n capi-operator-system
kubectl apply -f capi-components.yaml
```

Generate a cluster spec:

```console
export SSH_KEY_NAME="k8s"
export HCLOUD_REGION="hel1"
export HCLOUD_CONTROL_PLANE_MACHINE_TYPE=cpx21
export HCLOUD_WORKER_MACHINE_TYPE=cpx21
export CONTROL_PLANE_MACHINE_COUNT=3
export WORKER_MACHINE_COUNT=1
export KUBERNETES_VERSION=v1.31.0
clusterctl generate cluster technat.dev -i=hetzner:v1.0.0-beta.43 > cluster.yaml
kubectl apply -f cluster.yaml
```

And finally access the workload cluster:

```console
export CAPH_WORKER_CLUSTER_KUBECONFIG=/tmp/workload-kubeconfig
clusterctl get kubeconfig technat.dev > $CAPH_WORKER_CLUSTER_KUBECONFIG
export KUEBCONFIG=$CAPH_WORKER_CLUSTER_KUBECONFIG
helm upgrade --install cilium cilium/cilium --version 1.16.0 --namespace kube-system 
helm repo add hcloud https://charts.hetzner.cloud
helm upgrade --install hccm hcloud/hcloud-cloud-controller-manager \
        --namespace kube-system \
        --set env.HCLOUD_TOKEN.valueFrom.secretKeyRef.name=hetzner \
        --set env.HCLOUD_TOKEN.valueFrom.secretKeyRef.key=hcloud \
        --set privateNetwork.enabled=false
cat << EOF > csi-values.yaml
storageClasses:
- name: hcloud-volumes
  defaultStorageClass: true
  reclaimPolicy: Retain
EOF
helm upgrade --install csi syself/csi-hcloud --version 0.2.0 \
--namespace kube-system -f csi-values.yaml
```