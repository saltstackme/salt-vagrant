# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  
  config.vm.define "mighty" do |master|
    master.vm.box = "trusty"
    master.vm.host_name = "mighty"
    master.vm.network :private_network, ip: "192.168.56.100"
    master.vm.network "public_network", :bridge => 'en0: Ethernet (AirPort)'
    master.vm.provision :salt do |salt|
      # see options here: https://github.com/saltstack/salty-vagrant/blob/develop/example/complete/Vagrantfile

      salt.install_master = true
      salt.install_type = "stable"
    
      salt.minion_config = "salt/minion"
      salt.master_config = "salt/master"

      salt.minion_key = "salt/minion.pem"
      salt.minion_pub = "salt/minion.pub"

      salt.master_key = "salt/master.pem"
      salt.master_pub = "salt/master.pub"      
    end

    master.vm.provision "shell", path: "scripts/provision.sh"

  end

  config.vm.define "saltmaster" do |minion|    
    minion.vm.box = "trusty"
    minion.vm.host_name = "saltmaster"
    minion.vm.network :private_network, ip: "192.168.56.102"
    minion.vm.network "public_network", :bridge => 'en0: Ethernet (AirPort)'
    minion.vm.provision :salt do |salt|
      salt.run_highstate = true

      salt.minion_config = "./salt/minion"

      salt.minion_key = "./salt/minion.pem"
      salt.minion_pub = "./salt/minion.pub"
    end 
  end  

end
