# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative 'config'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if PROVIDER == "rackspace"
    DEST = "/root"

    config.vm.provider :rackspace do |rs, override|
      rs.username        = "#{RACKSPACE_USER}"
      rs.api_key         = "#{RACKSPACE_KEY}"
      rs.flavor          = /1 GB Performance/
      rs.image           = /Ubuntu/
      rs.rackspace_region= :iad
      rs.public_key_path = "/root/.ssh/id_rsa.pub"
      override.vm.box = "dummy"
      override.ssh.private_key_path = "/root/.ssh/id_rsa"
    end
  else
    DEST = "~"

    config.vm.provider "virtualbox" do |v, override|
      v.gui = false
      override.vm.box = "trusty"
    end    
  end

  config.vm.define "#{PREFIX}-#{INSTANCE_NAME}" do |master|
    master.vm.host_name = "#{PREFIX}-#{INSTANCE_NAME}"
    
    if PROVIDER == "virtualbox"
      master.vm.network :private_network, ip: "192.168.56.100"
    end

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
      destination: "#{DEST}/.ssh/config"

    # copy my private key so I can checkout from private repo
    master.vm.provision "file", 
      source: "#{HOME}/.ssh/id_rsa", 
      destination: "#{DEST}/.ssh/id_rsa"

    # copy my public key
    master.vm.provision "file", 
      source: "#{HOME}/.ssh/id_rsa.pub",
      destination: "#{DEST}/.ssh/id_rsa.pub"

    # change ownership of /srv to vagrant 
    if PROVIDER == "virtualbox"
      master.vm.provision "shell", inline: "chown vagrant:vagrant /srv"
    end

    # ensure git is installed
    master.vm.provision "shell", inline: "apt-get install git -y"

    # clone salt-sandbox environment
    master.vm.provision "shell", inline: "git clone https://github.com/saltstackme/salt-sandbox.git /srv/salt-sandbox", privileged: false

    # clone given forked repo environment
    master.vm.provision "shell", inline: "git clone #{REPO} /srv/salt", privileged: false

    # set github username
    master.vm.provision "shell", inline: "git config --global user.name #{GITHUB_USERNAME}", privileged: false

    # set github e-mail address
    master.vm.provision "shell", inline: "git config --global user.email #{GITHUB_EMAIL}", privileged: false

    # create a temporary minion configuration for masterless execution
    master.vm.provision "file", 
      source: "salt/minion-masterless",
      destination: "/tmp/salt/minion"

    # run salt-sandbox formulas to configure salt-master
    master.vm.provision "shell", inline: "salt-call --local -c /tmp/salt state.highstate -l quiet"
    master.vm.provision "shell" do |s|
      s.inline = "salt-call --local -c /tmp/salt cloud_config.rackspace $1 $2 $3 $4 $5 -l quiet"
      s.args = ["#{PROVIDER_PREFIX}", "#{RACKSPACE_USER}", "#{RACKSPACE_KEY}", "#{RACKSPACE_ACCOUNT}", "#{PROVIDER_IMAGES}"]
    end
    
  end
end
