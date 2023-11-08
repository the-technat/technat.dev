# Akeyless

The secret store for everything.

## Setup

Just sign up using Github on [https://console.akeyless.io](https://console.akeyless.io)

## PKI

The concept says that apart from the K3s CA, there's one for the rest of the cluster. This one is created in akeyless and later interacted with via cert-manager.

To create this CA, do the following:

1. Create a new DFC Encryption Key named `primary` with type `rsa4096`
2. Create a new PKI Issuer named `primary_ca`, referencing the key create earlier
  - the CA is of type private
  - the ttl is 30 days
  - hostnames are enforced
  - subdomains are allowed
  - any names are allowed
  - a CN is required
  - the Organization for this CA is `the-technat`
  - the Country for this CA is `Switzerland`
  - the Province for this CA is `Bern`

## Integrations

### Github Actions

There are Github actions in this repository that use secrets from akeyless. Most of them use the [LanceMcCarthy/akeyless-action](https://github.com/LanceMcCarthy/akeyless-action).

But for this to work, we first need to authenticate Github actions to akeyless. This is done using OAuth2 / JWT. See the docs [here](https://docs.akeyless.io/docs/github-actions-community-plugin) for how to configure this.
