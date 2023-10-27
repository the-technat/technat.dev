# Tailscale

Some notes about the tailsale setup.

- The tailnet named 'the-technat.github' was created when I signedup using Github 
- The domain for the tailnet is 'crocodile-bee.ts.net' and was generated manually
- most features tailscale provides are enabled, including MagicDNS, HTTPS 
- new devices must be approved manually, thus automatic joining via key always needs pre-approved keys

The ACL is synced from this repo to the tailnet via an API key. The API key expires every 90 days, so it needs to be updated, but it's generic and can thus be used by other actions as well.

The Github Actions that deploy stuff are authenticated by an OAuth2 Client which is also generic and saved in the repo secrets. It can only read & write devices and use the tag `tag:acl-axiom`.