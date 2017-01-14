# CINF 401: Big data mining and analytics, Vagrant setup

## Requirements

- Vagrant (tested 1.9.1)
- Ansible (tested 2.2.0.0)
- qemu (tested 2.8.0)
- libvirt (tested 2.4.0)
- apt-cache-ng (tested v2-1)

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
Save the resulting XML definition with:

```
virsh -c qemu:///system pool-dumpxml > cinf401.xml
```

Add to `/etc/libvirt/storage` and symlink to `/etc/libvirt/storage/autostart`. The XML contents should be something like (here called 'delenn' instead of 'cinf401'):

```
<pool type='dir'>
  <name>delenn</name>
  <uuid>9e48057e-c7ff-4c0b-bdb1-d892a0305c4e</uuid>
  <capacity unit='bytes'>14765979877376</capacity>
  <allocation unit='bytes'>10438474686464</allocation>
  <available unit='bytes'>4327505190912</available>
  <source>
  </source>
  <target>
    <path>/bigdata/vms/virtimages</path>
    <permissions>
      <mode>0755</mode>
      <owner>1000</owner>
      <group>1000</group>
    </permissions>
  </target>
</pool>
```

## Vagrant

Install the libvirt plugin: `vagrant plugin install vagrant-libvirt`

Add missing files:

```
#       ansible/hadoop-2.7.3.tar.gz
#       ansible/hadoop-users.txt
#       ansible/id_rsa
#       ansible/id_rsa.pub
#       ansible/jdk-7u71-linux-x64.tar.gz
#       ansible/known_hosts
```

On the host, add a `cinf401` user and add the contents of `id_rsa.pub` to cinf401's `authorized_keys`.

Generate `known_hosts` by bringing up, say `namenode`, and the ssh'ing using vagrant. Now try to connect to the parent:

```
ssh -p 2222 -N -L3142:127.0.0.1:3142 cinf401@192.168.121.1
```

The `known_hosts` file will be generated.

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

Also SELinux may prevent a symlink to the `www` directory. Fix this:

```
sudo chcon -R -t httpd_sys_content_t /home/jeckroth/
```

(I'm not sure how far up the tree you need to run this command.)


