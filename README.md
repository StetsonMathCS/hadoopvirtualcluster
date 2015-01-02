
## libvirt configuration

```
sudo mkdir /usr/local/virtimages/cinf401
virsh -c qemu:///system
pool-create-as cinf401 dir --target /usr/local/virtimages/cinf401
```

