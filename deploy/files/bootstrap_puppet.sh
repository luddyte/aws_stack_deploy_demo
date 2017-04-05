#!/bin/bash

sudo apt-get -qq update
sudo apt-get install -yqq unzip wget vim jq curl

# puppet
sudo curl https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb -o puppetlabs-release.deb
sudo dpkg -i puppetlabs-release.deb
sudo rm -f puppetlabs-release.deb

# docker
sudo apt-get -qq remove docker docker-engine
sudo apt-get -qqy install apt-transport-https ca-certificates software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# install
sudo apt-get -qq update
sudo apt-get install -yqq puppet-agent docker-ce

# disable
sudo systemctl disable puppet
sudo systemctl stop puppet

# required modules
sudo /opt/puppetlabs/puppet/bin/puppet module install KyleAnderson-consul --version 2.1.1
sudo /opt/puppetlabs/puppet/bin/puppet module install dudemcbacon-nomad --version 0.0.3
