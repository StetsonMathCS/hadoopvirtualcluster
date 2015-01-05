VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "stetson-cinf401/trusty64"

  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = "kvm"
    libvirt.uri = "qemu:///system"
    libvirt.storage_pool_name = "cinf401"
    libvirt.memory = 4096
  end

  config.vm.define "namenode" do |namenode|
    namenode.vm.network "private_network", ip: "192.168.50.4"
    namenode.vm.network "forwarded_port", guest: 50070, host: 50070, gateway_ports: true, host_ip: "127.0.0.1"
    namenode.vm.hostname = "namenode"
    namenode.vm.provider :libvirt do |libvirt|
        libvirt.memory = 16384
    end
  end

  config.vm.define "resourcemanager" do |resourcemanager|
    resourcemanager.vm.network "private_network", ip: "192.168.50.5"
    resourcemanager.vm.network "forwarded_port", guest: 8088, host: 8088, gateway_ports: true, host_ip: "127.0.0.1"
    resourcemanager.vm.hostname = "resourcemanager"
  end

  config.vm.define "mrjobhistory" do |mrjobhistory|
    mrjobhistory.vm.network "private_network", ip: "192.168.50.6"
    mrjobhistory.vm.network "forwarded_port", guest: 19888, host: 19888, gateway_ports: true, host_ip: "127.0.0.1"
    mrjobhistory.vm.hostname = "mrjobhistory"
  end

  slaveids = (2..22)
  slaveids.each do |slaveid|
    config.vm.define "slave#{slaveid}" do |slave|
      slave.vm.network "private_network", ip: "192.168.51.#{slaveid}"
      slave.vm.hostname = "slave#{slaveid}"
    end
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "ansible/playbook.yml"
    slavehosts = []
    slaveids.each do |slaveid|
      slavehosts.push("slave#{slaveid}")
    end
    ansible.groups = { "namenode" => ["namenode"],
                       "resourcemanager" => ["resourcemanager"],
                       "mrjobhistory" => ["mrjobhistory"],
                       "slaves" => slavehosts }
  end

end

