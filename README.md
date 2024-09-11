# technat.dev

Technat's truly unique homelab.

The goal of this homelab is: 
- to have some fun
- study and get to learn new stuff
- figure out how close to 100% automation we can get
- try to proove that cluster-api is the future for cluster management

The homelab consists of a k8s cluster bootstrapped by Cluster-API. On the cluster we install some basic tooling ready for whatever application we want to try out.

Bootstrap:
- Github Action provisions an ephemeral kind cluster
- Infrastructure provider credentials are placed in the kind cluster
- CAPI Operator and CAPI are installed in the kind cluster using helm
- YAML defines my cluster
- CAPI provisions my cluster
- CAPI installs the CNI and Argo CD
- CAPI state is moved to the target cluster
- Target cluster self-registers in Argo CD
- Argo CD fetches app config from repo
- Argo CD deploys infrastructure tools
- kind cluster is destroyed
- CAPI is self-managing it's cluster

Some points to note:
- CAPI is the future for cluster management and thus it's worth investing into it
- Apart from some commands and some CI/CD everything is fully declarative YAML and GitOps
- Infrastructure and Platform are decoupled, switching Infrastructure provider is normal and intended by CAPI
- Infrastructure providers for many cloud providers exist, the cheapest one can always be choosen
- CAPI can bootstrap the cluster using the kubeadm provider (giving me the option to manually deal with the cluster later, if I want to practise for the CKA or CKS)

The tools I'm going to install are:
- Cilium (the CNI I want to have experience with)
- Argo CD (my familiar GitOps tool where I contribute)
- gateway api controller (ingress-nginx or cilium)
- storage provider (longhorn, rook, minio...)
- cert-manager

The cluster should be as independent of the underlying cloud as possible.

## Manual Steps

Nothing is 100% automated, so this list keeps track of steps that have been done manually:
- Create hcloud project
- Add hcloud api token to repo secrets
- hcloud project was added to [account-nuker](https://github.com/the-technat/account-nuker)
- mend renovate saas was enabled for the repository
- generate ssh-key pair and save in hcloud project as default key named `k8s` 

## Bootstrap

Docs:
- https://syself.com/docs/caph/getting-started/introduction
- https://cluster-api.sigs.k8s.io

All the relevant commands can be seen in the github workflow file.

### Generate cluster spec

The cluster-spec that's checked into the repo, has been generated using the following commands:

```console
export SSH_KEY_NAME="k8s"
export HCLOUD_REGION="hel1"
export HCLOUD_CONTROL_PLANE_MACHINE_TYPE=cpx21
export HCLOUD_WORKER_MACHINE_TYPE=cpx21
export CONTROL_PLANE_MACHINE_COUNT=3
export WORKER_MACHINE_COUNT=1
export KUBERNETES_VERSION=v1.31.0
clusterctl generate cluster technat.dev -i=hetzner:v1.0.0-beta.43 > cluster.yaml
```

If you update the CAPH provider, it's recommended to regenerate these specs.

### Continue

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