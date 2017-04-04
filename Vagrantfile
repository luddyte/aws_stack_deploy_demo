# -*- mode: ruby -*-
# vi: set ft=ruby :

# Set hostname's IP to make advertisement Just Work
$set_hostname = <<SCRIPT
sudo sed -i -e "s/.*nomad.*/$(ip route get 1 | awk '{print $NF;exit}') nomad/" /etc/hosts
SCRIPT

# Instal required software (and some for convenience)
$install_things = <<SCRIPT
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y unzip curl wget vim jq
wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
sudo dpkg -i puppetlabs-release-pc1-xenial.deb
sudo apt update
sudo apt-get install puppet-agent
rm puppetlabs-release-pc1-xenial.deb
sudo systemctl disable puppet
sudo systemctl stop puppet
sudo /opt/puppetlabs/puppet/bin/puppet module install KyleAnderson-consul --version 2.1.1
sudo /opt/puppetlabs/puppet/bin/puppet module install dudemcbacon-nomad --version 0.0.3
SCRIPT

# vagrant puppet provisioner is not working so run puppet manually
$run_puppet_on_server = <<SCRIPT
sudo /opt/puppetlabs/puppet/bin/puppet apply /tmp/consul_server.pp
sudo /opt/puppetlabs/puppet/bin/puppet apply /tmp/nomad_server.pp
SCRIPT

$run_puppet_on_agent = <<SCRIPT
sudo /opt/puppetlabs/puppet/bin/puppet apply /tmp/consul_agent.pp
sudo /opt/puppetlabs/puppet/bin/puppet apply /tmp/nomad_agent.pp
SCRIPT

#TODO: build docker image and upload to local repository
$prepare_image = <<SCRIPT

docker run -d -p 5000:5000 --restart=always --name registry \
  -v /home/ubuntu/data:/var/lib/registry registry:2
SCRIPT

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64" # 16.04 LTS
  config.vm.provision "shell", inline: $install_things, privileged: false
  config.vm.provision "docker" # Just install it

  # vagrant puppet provisioner is not working so copy the files manually
  config.vm.provision "file", source: "./files/consul_agent.pp", destination: "/tmp/consul_agent.pp"
  config.vm.provision "file", source: "./files/consul_server.pp", destination: "/tmp/consul_server.pp"
  config.vm.provision "file", source: "./files/nomad_agent.pp", destination: "/tmp/nomad_agent.pp"
  config.vm.provision "file", source: "./files/nomad_server.pp", destination: "/tmp/nomad_server.pp"
  config.vm.provision "file", source: "./services/dataservice_docker.nomad", destination: "~/dataservice_docker.nomad"
  config.vm.provision "file", source: "./services/dataservice_raw.nomad", destination: "~/dataservice_raw.nomad"
  config.vm.provision "file", source: "./services/application.nomad", destination: "~/application.nomad"
  config.vm.provision "file", source: "./services/cache.nomad", destination: "~/cache.nomad"

  # Increase memory for Parallels Desktop
  config.vm.provider "parallels" do |p, o|
    p.memory = "1024"
  end

  # Increase memory for Virtualbox
  config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus   = "2"
  end

  # Increase memory for VMware
  ["vmware_fusion", "vmware_workstation"].each do |p|
    config.vm.provider p do |v|
      v.vmx["memsize"] = "1024"
    end
  end

  # For demonstration purposes we are running a single nomad and consul server
  # Production would require 3 or 5 instances
  config.vm.define "server" do |server|
    server.vm.hostname = "server"
    server.vm.network "private_network", ip: "192.168.50.4"
    server.vm.provision :hosts, :sync_hosts => true
    server.vm.provision "shell", inline: $run_puppet_on_server, privileged: false
    server.vm.provision "shell", inline: $set_hostname, privileged: false
  end

  # The worker VMs will run the containerized apps
  config.vm.define "worker1" do |worker1|
    worker1.vm.hostname = "worker1"
    worker1.vm.network "private_network", ip: "192.168.50.5"
    worker1.vm.provision :hosts, :sync_hosts => true
    worker1.vm.provision "shell", inline: $run_puppet_on_agent, privileged: false
  end

  config.vm.define "worker2" do |worker2|
    worker2.vm.hostname = "worker2"
    worker2.vm.network "private_network", ip: "192.168.50.6"
    worker2.vm.provision :hosts, :sync_hosts => true
    worker2.vm.provision "shell", inline: $run_puppet_on_agent, privileged: false
  end

  # This runs our "legacy" database
  config.vm.define "db", autostart:true do |db|
    db.vm.hostname = "db"
    db.vm.network "private_network", ip: "192.168.50.7"
    db.vm.provision :hosts, :sync_hosts => true
    db.vm.provision "shell", inline: $run_puppet_on_agent, privileged: false
    db.vm.provision "shell", inline: "sudo apt-get install -y mongodb; sudo systemctl disable mongodb; sudo systemctl stop mongodb", privileged: false

    db.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus   = "2"
    end
  end
end
