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

## libvirt configuration

```
sudo mkdir /usr/local/virtimages/cinf401
virsh -c qemu:///system
pool-create-as cinf401 dir --target /usr/local/virtimages/cinf401
```

