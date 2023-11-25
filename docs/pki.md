# PKI

All of the commands in this guide were generated using the akeyless-cli in version `1.85.0.acc06f4`.

Before we begin, grab your token to interact with akeyless: `akeyless auth --access-type oidc --oidc-sp=github`

## Axiom Root CA

First create the root key/cert:


```
akeyless create-dfc-key --name "/axiom/ca/root" \
  --alg RSA4096 \
  --generate-self-signed-certificate true \
  --certificate-ttl 3650 \
  --certificate-common-name "Axiom Root CA" \
  --certificate-country Switzerland \
  --certificate-organization "Axiom"
```

Now we have our root ca. But as we all know we don't use the root ca that often. Therefore let us create an issuer for the Root CA that can sign intermediate CAs:

```
akeyless create-pki-cert-issuer --name "/axiom/ca/root_issuer" \
  --signer-key-name "/axiom/ca/root" \
  --ttl 31536000 \
  --destination-path /axiom/ca/intermediate \
  --expiration-event-in 30 \
  --country Switzerland \
  --organizations Axiom \
  --allow-any-name \
  --not-enforce-hostnames \
  --allow-subdomains \
  --is-ca
```

This means: the Root CA is valid 10 years and certificates issued by the CA are valid for 1 year.

So intermediate CAs need to be rotated once a year.

## Axiom K3s CA (intermediate)

Now that we have the issuer, let's issue an intermediate CA for K3s:

```
akeyless generate-csr --name "/axiom/ca/intermediate/k3s" \
   --generate-key \
   --alg RSA4096 \
   --common-name "Axiom Intermediate K3s CA" \
```
