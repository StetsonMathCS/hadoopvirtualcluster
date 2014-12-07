VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "stetson-cinf401/trusty64"

  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = "kvm"
    libvirt.uri = "qemu:///system"
    libvirt.storage_pool_name = "cinf401"
    libvirt.memory = 512
  end

  config.vm.define "name_node" do |name_node|
    hadoop_master.vm.network "private_network", ip: "192.168.50.4"
    hadoop_master.vm.hostname = "name_node"
  end

  config.vm.define "resource_manager" do |resource_manager|
    hadoop_master.vm.network "private_network", ip: "192.168.50.5"
    hadoop_master.vm.hostname = "resource_manager"
  end

  config.vm.define "hadoop_slave1" do |hadoop_slave1|
    hadoop_slave1.vm.network "private_network", ip: "192.168.50.6"
    hadoop_slave1.vm.hostname = "slave1"
  end

  config.vm.define "hadoop_slave2" do |hadoop_slave2|
    hadoop_slave2.vm.network "private_network", ip: "192.168.50.7"
    hadoop_slave2.vm.hostname = "slave2"

    # only do ansible on last host, to be sure the others are up
    hadoop_slave2.vm.provision "ansible" do |ansible|
      ansible.inventory_path = "inventory"
      ansible.playbook = "ansible/playbook.yml"
      ansible.verbose = "vv"
    end
  end

end

