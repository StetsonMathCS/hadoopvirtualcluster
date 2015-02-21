# CINF 401: Big data mining and analytics, Vagrant setup

## Vagrant

Missing files:

```
#       ansible/hadoop-2.6.0.tar.gz
#       ansible/hadoop-users.txt
#       ansible/id_rsa
#       ansible/id_rsa.pub
#       ansible/jdk-7u71-linux-x64.tar.gz
#       ansible/known_hosts
```

## Host configuration

`/etc/sudoers`:

```
Cmnd_Alias MUNIN_RESTART = /sbin/service munin-node restart
%wheel ALL=(root) NOPASSWD: MUNIN_RESTART
```

Run `setup-hadoop.sh` as a user in the `wheel` group.

### libvirt configuration

```
sudo mkdir /usr/local/virtimages/cinf401
virsh -c qemu:///system
pool-create-as cinf401 dir --target /usr/local/virtimages/cinf401
```


## Apache config

Requires 2.2+

If you see:

```
Permission denied: proxy: HTTP: attempt to connect ...
```

then SELinux is preventing Apache `httpd` from making network connections. Run this:

```
sudo /usr/sbin/setsebool httpd_can_network_connect 1
```

