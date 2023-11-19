# [axiom](https://pixar.fandom.com/wiki/Axiom)

My personal Kubernetes cluster to host all my stuff.

## Why?

As a computer scientist you tend to solve IT problems with custom solutions. Some might programm their own app, others might search for an app and selfhost it. So do I. I got the following services that are hosted at some providers, sometimes maintained by me and sometimes as a Service:

- cloud.technat.ch: My personal Nextcloud
- collabora-online.fly.dev: Collabora Online Server used within the Nextcloud to edit rich-text documents
- vpn.technat.ch: A VPN service to securly browse the web from abroad
- flasche.alleaffengaffen.ch: The minecraft server of my colleagues (I'm not a gamer, but I can host servers)
- foto.js-buchsi.ch: [Lychee](https://lycheeorg.github.io/) based photo gallery
- many more projects to come in the future

Now I realized that they are spread over a dozent of different providers, all requiring some sort of monthly fee for their service. Although most of them have a good prive/value ratio, some apps don't. So the goal of axiom is to create a "centralized" place for all these services, so that we have:
- one fee
- all services in one place and under my control
- a home for new projects coming up
- something to practice your IT knowledge on

Before we dive into the details of the solution, let's define some hard requirements the solution must offer:

- backup: we host productive services there that must have some serious backup-system
- low maintenance effort: the inital effort might be high, but maintenance once every two months or less frequent is desirable
- scalability: when we need more compute, we simple add new servers (horizontal scaling)
- potential for high-availbility: we don't build HA, but we also don't intentionally prevent it. As much as possible the solution should be designed so that HA is possible. Exceptions are allowed if the effort/cost is not worth it

### A word about privacy

If someone hosts services on there own, one of the primary goals he has might be privacy. Now you haven't read this word in my concept so far, because that's not my primary focus. Of course privacy will be a lot better with self-hosted services, but it could be made better by far. Just think about Tailscale. Theoretically they could know everything what's happening. In addition data (either backup or block-storage) is stored on a provider, so you have to trust them that your data is secure there.

## Technical Overview

Since I'm a Kubernetes Engineer, the solution will be a Kubernetes cluster with all services beeing containerized. As Kubernetes distribution I'm using K3s as it has batteries included (which helps to reduce maintenance in my opinion) and it's lightweight, saving costly compute.

The why section said it shall be a central solution. This has to be understood in more of a symbolic way. It's one cluster managed with the same set of tools. But in terms of phyiscal location the cluster is spread over a good number of places. This is done to save money and spin up compute wherever it's currently cheap. To make this happen, I base the cluster-networking on [Tailscale](https://tailscale.com), so that nodes can be in any network anywhere on the world. This is a dramatic decision as it makes the network a Single-Point-Of-Failure (SPOF), which we tolerate to achieve higher goals. Currently I got nodes on [Infomaniak](https://infomaniak.com), [Hetzner](https://hetzner.de) and some at home.

## Technical deep dive

Some topics need further discussion.

### Architecture

We use `amd64` and `arm64` nodes mixed. If something doesn't run on `arm64` due to whatever reason, it should use [Node Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) to control it's placement.

### Naming

A word about naming: naming is hard and complex, therefore we have stupid names.

Axiom is the entire cluster, because that's the big spaceship out of the disney movie "WALL-E" (2007).

The masters / servers are nummbered with the prefix `M-O` for the very clever and observant vacuum cleaner robot aboard axiom.

The workers / agents are nummbered with the prefix `WALL-A` for the big clunky robots that compress garbage to cubes aboard axiom.

### Automation

It's not necessary to automate this solution and it should be carefully considered before automating a certain part.

Some reasons for it are:
- reproducable in case of a desaster
- automatic documentation of what has been done (not necessairly for someone to understand the thing, but for me as a reference)

Some reasons against it are:
- takes way more time to automate stuff so that it actually works automated
- you will always have some manual work you can't automate
- automating something for only a single environment doesn't really make sense
- the potential for failures is much higher if you automate stuff

For me the negative sides are more than the positive sides and after some inital trials with [Terraform](https://terraform.com) and [Ansible](https://ansible.com) I decided against automating any of the Infrastructure/Cluster side of things. The only thing I will use is GitOps and self-managed components once the cluster is more or less working.

### DNS

We use the dns zone `axiom.technat.ch` for everything related to the cluster (e.g APIs, nodes, infrastructure services...). The zone is registered by Infomaniak. All records will be public regardless whether they contain a private or public IP.

Due to how the zone is hosted, it can not be accessed by [external-dns](https://github.com/kubernetes-sigs/external-dns). We thus set DNS entires manually or are using wildcards. 

Services exposed externally on the cluster may of course use other DNS zones as well, but then without automation (e.g no external-dns).

### Backup

The storage for all backups shall be an S3 bucket somewhere in Infomaniak.

This means either an Openstack Swift container or Infomaniak Swiss Backup solution.

### CNI

To drive the pod/service networking I use [Cilium](https://cilium.io) with overlay networking. This is mainly to keep my knowledge around Cilium up to date, for an easy/maintenance-free setup the built-in CNI [Flannel](https://github.com/flannel-io/flannel) would of course be better.

If for any reason we switch CNI in the future, these things are important:
- Implementation of Network Policies and preferably also a custom implementation with more features
- some sort of visibility into the network flow logs (either via CLI or WebUI)
- it must be able to deal with multiple interfaces on the nodes (e.g because the nodes use `tailscale0` and not their primary interface for communication)

### Secrets

There is only one place for secrets: Akeyless SaaS Platform.

But there might be some tokens to access akeyless in various places, if they cannot use some nicer auth method (like OAuth2)

[Akeyless](https://akeyless.io) is a SaaS Solution for managing secrets and integrates well with Kubernetes. You can find the Console here: [Link](https://console.akeyless.io) (Login with Github)

### TLS

Kubernetes highly depends on TLS to secure internal communication. So we need a good management of CAs. To start with, there will be two CAs:

- the one k3s automatically generates and manages during the installation -> we don't touch nor export this one
- an `axiom CA` we create in akeyless for everything else that requires TLS

They have no relation to each other nor do they trust each other.

### Exposing services

Internal services must be accessible on a subdomain of `axiom.technat.ch` within the tailnet, external services may be accessible on any domain and IP.

Since our networking model is a bit complex, we rely on [servicelb](https://docs.k3s.io/networking#service-load-balancer) to implement LoadBalancer functionality. It comes builtin with K3s and does the job without requiring any additional infrastructure.

We define the following labels for use with the servicelb:

- `svccontroller.k3s.cattle.io/enablelb=true`: All worker nodes contain this label
- `svccontroller.k3s.cattle.io/lbpool=internal`: All worker nodes contain this label 
- `svccontroller.k3s.cattle.io/lbpool=external`: All worker nodes that advertise a public IP (e.g the `ExternalIP` field is populated correctly) contain this label

The labels must be applied manually after joining a new node. 

There are no special concepts/ideas about Ingress/Gateway API implementations. The easiest will be to use Cilium for that job, but any other Ingress Controller will do the job as well. Separation of external and internal traffic on two different Ingress Controllers is currently not required.

### Operating systems

We only use Linux for our task. Currently the focus is on Ubuntu 22.04, but that could change in the future. 

Since we don't manage Infrastructure declaritively, there's a document that shows how my servers are usually configured before they are joined the cluster.

### Level of services

The services are categorized into different levels that all represent an Argo CD sync wave and a priority class in K8s.

We have:
- -5/2000001000: node-critical service: only cilium-agent 
- -4/2000000000: cluster-critical service: only cilium-operator
- -3/1000000000: core service: cert-manager, eso, argocd, hubble
- -2/100000000: infrastructure service: csi-drivers, monitoring
<!-- - -1/10000000: regular infra service  -->
- 0/1000000: workload

All levels from `-5` to `-1` combined represent the infrastructure of the cluster. So sometimes I call them infrastructure.

