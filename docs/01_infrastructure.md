# 01 - Infrastructure

## Network

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

## Compute

We have no special requirements on compute in terms of it's location. Run them wherever it's cheap. 

The minimum we need is:
- console access (a password set is recommmended)
- flatcar or ubuntu linux
- ssh access (technically not really required)


## Storage

### Backup

An s3 bucket somewhere is required to backup k3s itself. Location doesn't matter as long as it's publicly available.


-> [02 - K3s](./02_k3s.md)