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
helm upgrade -i cert-manager -n cert-manager jetstack/cert-manager -f values/initial-cert-manager-values.yaml
kubectl apply -f values/initial-pki-issuer.yaml
```

## Argo CD

And as a last measurement, deploy Argo CD which will take care of all the other onboarding.

```
helm repo add argo https://argoproj.github.io/argo-helm
kubectl create namespace argocd
kubectl label ns argocd axiom.technat.ch/infrastructure="true"
helm upgrade -i argocd --create-namespace -n argocd argo/argo-cd -f values/initial-argocd-values.yaml
kubectl apply -f values/initial-app-of-apps.yaml
```