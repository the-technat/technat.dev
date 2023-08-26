## K3s

### Prerequisites

- Get [k3sup](https://github.com/alexellis/k3sup) to all of your nodes.
- Generate a pre-approved tailscale machine key that is already tagged for k3s (each machine needs his own key)
- Generate a pair of s3 access-keys for the backup bucket (see https://docs.infomaniak.cloud/documentation/04.object-storage/010.s3/) -> save the key in our vault

### Installation

Once k3sup is installed on your nodes, get a shell somehow and start bootstraping the first server node:

```
k3sup install --cluster --local --k3s-extra-args \
  '--cluster-cidr 10.127.0.0/16 
   --service-cidr 10.227.0.0/16  \
   --vpn-auth=name=tailscale,joinKey=tskey-auth-xxxxxx-YYYYYYYYYY \
   --etcd-s3 \
   --etcd-s3-endpoint	https://s3.pub1.infomaniak.cloud/
   --etcd-s3-access-key= \
   --etcd-s3-secret-key=	\
   --etcd-s3-bucket=axiom-k3s-backup	\ 
   --etcd-s3-folder=k3s \
   '
```



### Cert-Manager

Docs: https://cert-manager.io/docs/

everything shall use TLS, therefore we deploy cert-manager right now using an inital helm install command. Later on it will be managed by Argo CD.

Cert-manager has an integration into akeyless.io for private CA certs and one into Infomaniak for DNS-01 challenges.

#### Preparations

First generate the axiom CA using this docs: https://docs.akeyless.io/docs/cli-reference-certificates#p-stylecolorbluecreate-pki-cert-issuerp (can also be created in the UI).

Then add the repo:

```
helm repo add jetstack https://charts.jetstack.io
```

#### Installation

```
helm upgrade -i \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.12.x \
	--set installCRDs=true
```

#### Configuration

The issuer for akeyless:

```yaml
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: akeyless-api
data:
  token: "cC04Y2l0eelfkjsfijlskjfklsflfskdfjlkfkzRVk9" # access_id..acces_key | base64
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: akeyless-ca
spec:
  vault:
    path: "pki/sign/axiom/ca/AxiomCA"
    server: http://api.akeyless.io
    auth:
      tokenSecretRef:
          name: akeyless-api
          key: token
```

And the issuer for infomaniak:

https://github.com/Infomaniak/cert-manager-webhook-infomaniak

### External-Secrets

In order for secrets to be synced, we deploy external-secrets which can sync secrets from akeyless.io. 

For this we manually create a static secret with credentials which external-secret should use:

#### akeyless.io

A SaaS platform to store secrets. 

I created a folder there named `axiom`, and a new role named `axiom` which has read permissions on everything below /axiom. For the role I created an API key that is assiocated with the role and saved in the following secret:

```yaml
kubectl create namespace secrets
kubectl create secret generic -n secrets akeyless-auth  --from-literal accessId="" --from-literal accessType="api_key" --from-literal accessTypeParam=""
```

## Infra Services

### Public Ingress

- https://stackoverflow.com/questions/34724160/go-http-send-incoming-http-request-to-an-other-server-using-client-do
- https://tailscale.dev/blog/embedded-funnel

