# 00 - Basics & Infrastructure

## Introduction

This is the documentation I wrote for my personal K8s cluster.
Why I wrote a documentation about it? Well I'm presumably one of those strange engineers that likes writting docs. Or maybe it's just to that you can learn something from me and I still know how everything has been built?

Anyway, let's get started with some important topics

## Basics

For basic principles in my homelab see the [.github](https://github.com/alleaffengaffen/.github) repo.

For the cluster here some architectural decisions:

- we are running k8s on the public net
- we use cilium to secure the traffic between nodes (wireguard, host firewall)
- we use Ubuntu 22.04 as OS for nodes
- we keep an emergency serial console access
- HA is no requirement but shoulnd´t be made impossible by design decisions

## Infrastructure

### Control Plane

I only run a sigle node as my control-plane with local etcd as it's simpler, easier to restore and uses fewer resources (which are expensive for a homelab that's mainly for fun). You can extend at any time if you need.

This node is currently running on [Hetzner Cloud](https://www.hetzner.com/de/cloud).

There I have created a project `banana` and added the following resources:

- SSH-Key which is the default key
- A `hawk` with the following specs:
  - located in Falkenstein
  - type CPX11
  - Ubuntu 22.04
  - with backups enabled
  - some tags: `role=master` and `cluster=banana`
  - only public IPv4

### Worker Nodes

I have as many workers as I need, due to my network typology the only requirements for a worker node are:

- a public IPv4
- **no firewall blocking any traffic on this public net**
- emergency console access
- (ssh access) convenient but not a requirement

## Next Step

-> [01 - Operating System](./01_os.md)
