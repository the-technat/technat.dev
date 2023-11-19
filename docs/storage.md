# Storage

## Network Storage

For Persistent Volumes, I ordered a Hetzner Storage Box that can be accessed via SMB. The creds are saved in akeyless, but no other config was done.

## Backup

### Location

We use Infomaniak Swiss Backup (S3-compat layer) for our backups. There's one for the etcd snapshots, and one for persistent volumes.

### Cluster (etcd)

First create an application credential limited to the usage of Swift, then create some ec2 credentails for this app credential and create a swift container.

To generate ec2 creds, you need to download the openrc file, source it in a shell and then use the cli to run `openstack ec2 credentials create`.

To backup etcd, the following options have to be added to the `/etc/rancher/k3s/config.yaml` file on all control-plane nodes:

```
etcd-s3: true
etcd-s3-endpoint: s3.swiss-backup03.infomaniak.com
etcd-s3-access-key: eerwerwewer
etcd-s3-secret-key: lrkjweklrjwrj2489
etcd-s3-bucket: default
etcd-s3-folder: k3s
```

Then one can do on-demand snapshots like this:

```
sudo k3s etcd-snapshot save
```

On more informations about how to restore the cluster with these snapshots, see [this page](https://docs.k3s.io/cli/etcd-snapshot#options).
