# Core Addons

When the cluster is initialized and running, one can continue deploying some critical core addons manually.

## External-Secrets Operator (ESO)

The [External Secrets Operator](https://external-secrets.io/latest/introduction/getting-started/) is responsible for syncing secrets form our vault (akeyless) to the cluster.

In order to deploy him, we first need to create an api_key and role in akeyless. Assign the role access to `/axiom/infrastructure/*`

```
helm repo add external-secrets https://charts.external-secrets.io
helm upgrade -i eso external-secrets/external-secrets --create-namespace -n external-secrets -f values/inital-eso-values.yaml
kubectl create secret generic  akeyless-secret-creds -n external-secrets --from-literal accessType="api_key" --from-literal accessId="<access_id>"  --from-literal accessTypeParam="<api_key>"
kubectl apply -f values/inital-eso-configs.yaml
```

## Cert-Manager

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