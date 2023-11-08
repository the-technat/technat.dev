# Core Addons

When the cluster is initialized and running, one can continue deploying some critical core addons manually.

## External-Secrets Operator (ESO)

The [External Secrets Operator](https://external-secrets.io/latest/introduction/getting-started/) is responsible for syncing secrets form our vault (akeyless) to the cluster.

In order to deploy him, we first need to create an api_key and role in akeyless. Assign the role access to `/axiom/infrastructure/*`

```
helm repo add external-secrets https://charts.external-secrets.io
helm upgrade -i eso external-secrets/external-secrets --create-namespace -n external-secrets -f values/inital-eso-values.yaml
kubectl create secret generic  akeyless-infrastructure-creds -n external-secrets --from-literal accessType="api_key" --from-literal accessId="<access_id>"  --from-literal accessTypeParam="<api_key>"
kubectl apply -f values/inital-eso-infrastructure-store.yaml
```

Don't forget to label the namespaces which needs access to infrastructure secrets!

## Cert-Manager

[Cert-manager](https://cert-manager.io/docs/installation/) is used for all certificates management. The concept says that there are two CAs, from which one is managed by Akeyless. Cert-manager is thus also used to generate certificates from this PKI.

Before you install cert-manager, create an api_key and auth_method. Assign the role read access to `/axiom/ca/*`.

```
kubectl create namespace cert-manager 
kubectl label ns cert-manager axiom.technat.ch/infrastructure="true" 
kubectl create secret generic akeyless-creds --from-literal  secretId=<access_key> --from-literal accessId=<access_id> -n cert-manager
helm repo add jetstack https://charts.jetstack.io
helm upgrade -i cert-manager -n cert-manager jetstack/cert-manager -f values/inital-cert-manager-values.yaml
kubectl apply -f values/initial-pki-issuer.yaml
```

## Argo CD

```
helm repo add external-secrets https://charts.external-secrets.io
helm upgrade -i external-secrets external-secrets/external-secrets --create-namespace -n external-secrets
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: akeyless-secret-creds
type: Opaque
stringData:
  accessId: "p-XXXX"
  accessType:  api_key
  accessTypeParam: "access_secret"
EOF
cat <<EOF | kubectl apply -f -
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: akeyless-secret-store
spec:
  provider:
    akeyless:
      akeylessGWApiURL: "https://api.akeyless.io"
      authSecretRef:
        secretRef:
          accessID:
            name: akeyless-secret-creds
            key: accessId
            namespace: external-secrets
          accessType:
            name: akeyless-secret-creds
            key: accessType
            namespace: external-secrets
          accessTypeParam:
            name: akeyless-secret-creds
            key: accessTypeParam
            namespace: external-secrets
EOF
```