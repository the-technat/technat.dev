# 03 - Core Services

## External-Secrets

In order for secrets to be synced, we deploy external-secrets which can sync secrets from akeyless.io. 

For this we manually create a static secret with credentials which external-secret should use:

### akeyless.io

A SaaS platform to store secrets. 

I created a folder there named `axiom`, and a new role named `axiom` which has read permissions on everything below /axiom. For the role I created an API key that is assiocated with the role and saved in the following secret:

```yaml
kubectl create namespace secrets
kubectl create secret generic -n secrets akeyless-auth  --from-literal accessId="" --from-literal accessType="api_key" --from-literal accessTypeParam=""
``` 