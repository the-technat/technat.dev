# Axiom

This is the only documentation that exists for axiom.

## 01 - Concept

> Normally I write concepts but don't actually implement them, so this concept isn't yet finished but therefore I started implementing it

There's an ongoing demand for self-hosting a couple of applications, which should be cost-effective and centralized.

So we need a solution that offers:
- scalability as needed 
- low maintenance effort 
- backup and no data-loss

but excludes:
- true HA (although keeping the possibility would be nice)
- automation (one-time install)

### Stakeholders
Here's a list of stakeholders for this solution:
- wunsch.silvermail.ch (potentially)
- foto.js-buchsi.ch
- fpvhub.ch (potentially)
- fpv-enthusiasts.ch (potentially)
- vpn.technat.ch
- cloud.technat.ch
- office.technat.ch
- flasche.alleaffengaffen.ch
- DIY projects like weddingphone backend

Please note that there are productive and non-productive stakeholders in this list.

### Cost comparison

Here's what I currently pay per month to cover these services:
- 10.90.- for webhosting
- 11.- for VPN (could also be 5.-)
- 4.29€ for Nextcloud
- 4.25€ for Mincraft server
- 3.- for Domains
- nothing for mails
- some bucks for testing servers (hard to replace due to cloud provider deps and unregular usage)
- nothing for fly.io services (onlyoffice)

Obviously the goal is to beat that in price.

### Choosing a place

Some thoughts about the right place in terms of compute:
- SaaS -> either very cheap or out of reach, depending on the use-case
- Paas -> fly.io, Heroku or Jelastic are in my experience so far more expensive than IaaS since you pay for the additional service but loose control over the data, mechanisms to deploy, except for web hostings
- Iaas -> most versatile option that's usually affordable but it creates more effort on our side
- DIY -> high cost in the beginning and cumbersome to manage, but in the long-term it could be the cheapest option, especially if we self-host things anyway.

#### Conclusion
The best fit is to rent a physical server because:
- you don't have to manage hardware
- you get new hardware every now and then
- your hardware runs in a DC instead of your home
- you have more performance compared to a VM for the same fee

Since we need to validate the solution bevore we choose it finally, we start with bare-metal @ home and evolve over time.

### Choosing a platform

I'm working as a Kubernetes engineer and most software I want to host recommends to install itself as a container, so there's no other option than a self-managed Kubernetes cluster.

Why k8s and not plain docker?
- scales more easily
- keeps your knowledge up to date

#### But which Kubernetes?
 
That's the trickiest part to decide, because there are many options. But since it will host productive services, there's only one option: k3s.

K3s is lightweight which never hurts, but much more important is that it has batteries included. Sometimes you don't want this, but here it really helps to ease deployment and management in the long-term. And since it's still k8s you won't lose that much knowledge.

For networking we opt for the Flannel+Tailscale integration since it provides secure remote-access and allows for global scalabity if needed. We intentionally don't deploy cilium.

Tailscale is just for scalability over other providers and secure remote-access.

K3s is lower in resource usage, which helps on small servers, but if we get a big one it might not play a role at all. It also looks better suited for single-node deployments, eases management and has some pretty damn good integration into tailscale.

k8s on the other hand is closer to the knowledge I need, but that's about all it has to offer.

###### ingress
internal: servicelb +traefik out of the box + wildcard dns + wildcard cert
external: custom funnel proxy + nginx

###### backup
automated to s3 out of the box

for PVs we need a solution anyway

###### certs

k3s creates and manages it's own CA for the cluster. This is considered the most reliable option.

for admission controllers and other internal usage we maintain our own CA that can be used via Cert Manager

All accessible Web UIs shall use Let's Encrypt Certificates

cert-manager + DNS-01 needed for infomaniak
https://github.com/Infomaniak/cert-manager-webhook-infomaniak

###### dns
wildcards or if external-dns adds support for native infomaniak, we use this

###### secrets
we use external secrets, as it's decoupled from the backend system and easy to setup.

As backend akeyless Saas is currently our choice since it's free and logged in with Github

##### External dependencies
- akeyless.io
- github.com
- infomaniak.com
- tailscale.com

two logins needed which are both backed by DR:
- github
- infomaniak

### Further reading
- https://stackoverflow.com/questions/34724160/go-http-send-incoming-http-request-to-an-other-server-using-client-do
- https://tailscale.dev/blog/embedded-funnel


## Infrastructure

### Network

The network for my cluster is a personal tailnet on [tailscale](https://tailscale.com). 

Here's the current ACL:

```json
{
	"tagOwners": {
		"tag:exitNode": [
			"autogroup:members",
		],
		"tag:funnel": [
			"autogroup:members",
		],
		"tag:trusted": [
			"autogroup:members",
		],
		"tag:k3s": [
			"autogroup:members",
		],
	},

	"autoApprovers": {
		// automatically accepts the advertise-exit-node flag from nodes taged like that
		"exitNode": ["tag:exitNode"],

		// k3s can automatically adervise routes in these CIDRs
		"routes": {
			"10.227.0.0/16": ["tag:k3s"],
			"10.127.0.0/16": ["tag:k3s"],
		},
	},

	"nodeAttrs": [
		// activates the funnel feature on nodes with that tag
		{
			"target": ["tag:funnel"],
			"attr":   ["funnel"],
		},
	],

	"acls": [
		// internet is always open for everyone (also via exitNodes)
		{"action": "accept", "src": ["*"], "dst": ["autogroup:internet:*"]},
		// k3s can communicate with itself anyways
		{"action": "accept", "src": ["tag:k3s"], "dst": ["tag:k3s:*"]},
		// only this tag can access other nodes
		{"action": "accept", "src": ["tag:trusted"], "dst": ["*:*"]},
	],

	"ssh": [
		{
			"action": "accept",
			"src":    ["tag:trusted"], // only trusted devices can ssh into other nodes
			"dst":    ["tag:trusted"],
			"users":  ["autogroup:nonroot", "root"],
		},
		{
			"action": "accept",
			"src":    ["tag:trusted"], // only trusted devices can ssh into other nodes
			"dst":    ["tag:k3s"],
			"users":  ["autogroup:nonroot", "root"],
		},
		{
			"action": "accept",
			"src":    ["tag:trusted"], // only trusted devices can ssh into other nodes
			"dst":    ["tag:exitNode"],
			"users":  ["autogroup:nonroot", "root"],
		},
	],
}
```

Some notes:
- k3s nodes need to be able to communicate with itself & access the internet
- k3s nodes must be able to advertise routes that are preapproved

### Compute

We have no special requirements on compute in terms of it's location. Run them wherever it's cheap. 

The minimum we need is:
- console access (a password set is recommmended)
- flatcar or ubuntu linux
- ssh access (technically not really required)


### Storage

#### Backup

An s3 bucket somewhere is required to backup k3s itself. Location doesn't matter as long as it's publicly available.


-> [02 - K3s](./02_k3s.md)

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

## Core Services

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