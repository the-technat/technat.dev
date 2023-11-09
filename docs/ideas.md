# Ideas

This is a doc full of crazy ideas and things not fully ready. It also lists technical debts that need to be addressed sometime in the future.

## Technical Debts

To bring axiom to a first working version that can be used, some technical debts were explicitly created:

-  securityContext configs -> we just left everything on the defaults for all apps
- NetworkPolicies -> the hosts and all pods run without policies (or only default policies enabled in a chart)
  - audit mode is on, so policies can be applied one after the other

## Ideas

- Add falco/falcosidekick to monitor node activity
- Configure dependabot for automatic patching of helm charts
- Migrate from Ingress to Gatway API