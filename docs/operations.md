# Operations

Some knowledge how to do stuff

## Move control-plane node to new server

1. Create new server according to the OS guidelines
2. Join new server as additional control-plane node
  - Give them time to sync
  - Ensure the new control-plane node is fully functional
  - Test this by removing the old one from DNS, adding the new one
3. Drain the first control-plane node 
4. Delete the first control-plane node
5. Run the `k3s-uninstall.sh` script on the node

It's possible that after these steps the new control-plane node will look for his members. If this is the case, remove the `--server` and `--token` flag and add the `--cluster-reset` flag. After a daemon-reload and restart, the new control-plane node will reevaluate it's etcd members, eventually completly wiping the old control-plane node. Once this is done, remove the flag again and start regurarly.

## control-plane crashlook with etcd defragmentation

After some days of runtime, my etcd database became big and thus some tweakings were required.

I added `--etcd-arg=quota-backend-bytes=6442450944`  to all control-plane nodes, so that etcd is performing better.

See https://github.com/k3s-io/k3s/discussions/7299 for more details and a similar issue.