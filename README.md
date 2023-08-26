# [axiom](https://pixar.fandom.com/wiki/Axiom)

My personal Kubernetes cluster to host all my stuff

## Why?

As a computer scientist you tend to solve IT problems with custom solutions. Some might programm their own app, others might search for an app and host it themself. So do I. I got the following services that are hosted at some provider, sometimes maintained by me and sometimes as a Service:

- cloud.technat.ch: My personal Nextcloud
- office.technat.ch: Onlyoffice Documentserver used within the Nextcloud
- vpn.technat.ch: A VPN service to secure browse the web from abroad
- flasche.alleaffengaffen.ch: The minecraft server of my collages (I'm not a gamer but I can host servers)
- foto.js-buchsi.ch: Lychee based photo gallery
- fpvhub.ch & fpv-enthusiasts.ch: websites that might eventually be replatformed to static sites 
- many more projects to come in the future

Now I realized that they are spread over a dozent of different providers, all requiring some sort of monthly fee for their service. Although most of them have a good prive/value ratio, some apps don't. So the goal of axiom is to create a centralized place for all these services, so that we have:
- one fee
- all services in one place and under my control
- a home for new projects coming up
- something to practice your IT knowledge

Before we dive into the details of the solution, let's define some hard requirements the solution must offer:

- backup: we host productive services there that must have a backup
- low maintenance effort: the inital effort might be high, but maintenance once every two months and not more is the goal
- scalability: when we need more compute, we simple add new servers
- potential for high-availbility: we don't build HA, but we also don't intentionally prevent it. As much as possible the solution should be designed so that HA is possible. Exceptions are allowed if the effort/cost is not worth it

## Technical Overview

Since I'm a Kubernetes Engineer, the solution will be a Kubernetes cluster with all services beeing containerized. As Kubernetes distribution I'm using K3s as it has batteries included (which helps to reduce maintenance in my opinion) and it's lightweight, saving costly compute.

The why section said it shall be a central solution. Therefore the primary provider for this solution is [Infomaniak](https://infomaniak.com), with their [Public Cloud](https://www.infomaniak.com/en/hosting/public-cloud) offering. As many components as possible shall be deployed there. But to save some money on compute, we base the cluster-networking on [Tailscale](https://tailscale.com), so that we can join some worker nodes from other locations into the cluster.

So the main things needed for this solution are:
- an openstack project by Infomaniak
- a github repository to store configs
- a terraform workspace to run automation (best placed in an `axiom` project)
- an akeyless account to store secrets (best with Github as IDP)

## Technical deep dive

Some topics need further discussion.

### Naming

A word about naming: naming is hard and complex, therefore we have stupid names.

Axiom is the entire cluster, because that's the big spaceship out of the disney movie WALL-E (2007).

The masters / servers are nummbered with the prefix `M-O` for the very clever and observant vacuum cleaner robot.

The workers / agents are nummbered with the prefix `WALL-A` for the big clunky robots that compress garbage to cubes.

### Automation

It's not necessary to automate this solution, but we do out of two reasons:
- reproducable in case of a desaster
- automatic documentation 

To automate we mainly use [Terraform](https://www.terraform.io/) or GitOps with [Argo CD](https://argo-cd.readthedocs.io/en/stable/).

### DNS

We use the dns zone `axiom.technat.ch` for everything related to the cluster (e.g APIs, nodes, infrastructure services...). The zone is of course registered by Infomaniak and maintained in their public cloud.

Services exposed externally may use other DNS zones.

### Backup

The storage for all backups shall be an S3 bucket somewhere in Infomaniak.

This means either an Openstack Swift container or Infomaniak Swiss Backup.

### CNI

To drive the pod/service networking we use [Cilium](https://cilium.io) with overlay networking.

### Secrets

There are two places for secrets:
- either in the Terraform workspace 
- or in akeyless

[Akeyless](https://akeyless.io) is a SaaS Solution for managing secrets and integrates well with Kubernetes.

[Link](https://console.akeyless.io) (Login with Github)

### TLS

Kubernetes highly depends on TLS to secure internal communication. So we need a good management of CAs. To start with there will be two CAs:

- the one k3s automatically generates and manages during the installation
- an `axiom CA` we create in akeyless for everything else

They have no relation to each other nor do they trust each other.

### Exposing services

Internal services must be accessible on a subdomain of `axiom.technat.ch` within the tailnet, external services may be accessible on any domain and IP.

One possible solution would be a custom tailscale funnel proxy.

### Operating systems

We only use Linux for our task. Either Ubuntu or Flatcat Linux are prefered. But in general the following three requirements are all we need:
- console access via provider (a password is recommmended)
- optionall SSH access via tailscale

### Level of services

The services are categorized into different levels that all represent an Argo CD sync wave and a priority class in K8s.

We have:
- -5/2000001000: node-critical service
- -4/2000000000: cluster-critical service
- -3/1000000000: core service
- -2/100000000: almost core service 
- -1/10000000: regular infra service 
- 0/1000000: workload