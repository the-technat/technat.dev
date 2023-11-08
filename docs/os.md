# Operating System

## Setup new server

For servers that are running long-term I usually setup everything from scratch, because I have the time.

So here's the checklist:
- console access via provider's website/portal must be possible 
- root password must not be set (`sudo passwd -dl root`) -> prevents console + ssh login using password
- ssh is disabled and the service is masked 
- enable and configure `systemd-networkd` and purge `netplan.io` (or whatever networking service is there)
- the `secure_path` in `/etc/sudoers` contains `/usr/local/bin`
- user `technat` must exists (example: `sudo useradd -m -G sudo -s /bin/bash technat`)
  - password must be saved in akeyless 
  - user needs a home directory
  - user must be able to use sudo when entering his password (e.g member of `sudo` or `wheel`)
- tailscale must be installed and logged in (ssh, disabled key expiry + correct tags), thus enabling tailscale SSH access
- we don't care if nodes have a public IPv4, IPv6 or just a private IP, as long as they can join our tailnet we should be able to use it (maybe not for incoming traffic but for everything else)
- if you use any firewall within the cloud providers network, you must ensure egress traffic according to [tailscale docs](https://tailscale.com/kb/1082/firewall-ports/) is allowed, the wider they are open the better (we will use Cilium's host firewall later)

## Work on the control-plane nodes

On the first control-plane node I did some more configs:

- Run chezmoi (remote machine profile)
- Copied the kubeconfig to my user