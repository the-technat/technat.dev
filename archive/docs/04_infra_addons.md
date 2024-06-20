# 04 - Infrastructure Addons

After the core addons have been installed we can start onboarding all apps properly. This will be done using Argo CD.

Infrastructure addons are important too, but not crucial for the cluster to work properly, therefore they get the sync-wave `-3` and the priorityClass `infra`.

## GitOps - Argo CD

Start with a self-managed Argo CD instance:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade -i argocd argo/argo-cd -n argocd --create-namespace 
```

For now you can connect to Argo CD using the following command:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
kubectl port-forward svc/argocd-server 8080:80 # open http://localhost:8080
```

**Change the default admin password!**

## Onboarding

To start with the infrastrucutre addons, we deploy the app-of-apps for argocd which will also start managing Argo CD:

```bash
kubectl apply -f default-app-of-apps.yaml
```

This will onboard the app-of-apps which inturn will onboard all other apps from Git, including Cilium and Argo CD, so we got a self-managed Argo CD. Of course some things will break now and more than one reconcile-loop is necessary to get things up and running, but this is how K8s works ;).

We will see if argocd can handle self-managing, while activating default-deny in cilium, deploying default netpols and then also onboard much more tools from git.
