# Akeyless

The secret store for everything.

## Setup

Just sign up using Github on [https://console.akeyless.io](https://console.akeyless.io)

## Integrations

### Github Actions

There are many Github actions in this repository that use secrets from akeyless. Most of them use the [LanceMcCarthy/akeyless-action](https://github.com/LanceMcCarthy/akeyless-action).

But for this to work, we first need to authenticate Github actions to akeyless. This is done using OAuth2 / JWT. See the docs [here](https://docs.akeyless.io/docs/github-actions-community-plugin) for how to configure this.

### Ansible

the integration into ansible has not yet been used
