# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  
  config.vm.provider "virtualbox" do |v|
    v.gui = false
  end

  config.vm.define "sandbox" do |master|
    master.vm.box = "trusty"
    master.vm.host_name = "salt-sandbox"
    master.vm.network :private_network, ip: "192.168.56.100"
    #master.vm.network "public_network", :bridge => 'en0: Ethernet (AirPort)'

    # install salt-master, salt-minon
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

    # disable StrictHostKeyChecking for github
    master.vm.provision "file",
      source: "etc/ssh-config",
      destination: "~/.ssh/config"

    # various actions to get ready for masterless minion execution
    master.vm.provision "shell", path: "scripts/provision.sh"

    # copy my private key so I can checkout from private repo
    master.vm.provision "file", 
      source: "~/.ssh/id_rsa", 
      destination: "~/.ssh/id_rsa"

    # copy my public key
    master.vm.provision "file", 
      source: "~/.ssh/id_rsa.pub",
      destination: "~/.ssh/id_rsa.pub"

    # create a temporart minion configuration for masterless execution
    master.vm.provision "file", 
      source: "salt/minion-masterless",
      destination: "/tmp/salt/minion"

    # run salt-sandbox formulas to configure salt-master
    master.vm.provision "shell", inline: "salt-call --local -c /tmp/salt state.highstate"

  end

  config.vm.define "saltmaster" do |minion|    
    minion.vm.box = "trusty"
    minion.vm.host_name = "saltmaster"
    minion.vm.network :private_network, ip: "192.168.56.102"
    #minion.vm.network "public_network", :bridge => 'en0: Ethernet (AirPort)'
    minion.vm.provision :salt do |salt|
      salt.run_highstate = true

      salt.minion_config = "./salt/minion"

      salt.minion_key = "./salt/minion.pem"
      salt.minion_pub = "./salt/minion.pub"
    end 
  end  

end
