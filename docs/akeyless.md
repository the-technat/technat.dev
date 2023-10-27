# Akeyless

The secret store for everything.

## Setup

Just sign up using Github on [https://console.akeyless.io](https://console.akeyless.io)

## Integrations

### Github Actions

There are many Github actions in this repository that use secrets from akeyless. Most of them use the [LanceMcCarthy/akeyless-action](https://github.com/LanceMcCarthy/akeyless-action).

But for this to work, we first need to authenticate Github actions to akeyless. This is done using OAuth2 / JWT. See the docs [here](https://docs.akeyless.io/docs/github-actions-community-plugin) for how to configure this.

### Ansible

Ansible was integrated using [these docs](https://docs.akeyless.io/docs/ansible-plugin-secret-fetch-via-playbook-using-ansible-playbook-cli).

A token is generated on-the-fly within github actions, so ansible in theory inherits the permissions that the Github action already has.
