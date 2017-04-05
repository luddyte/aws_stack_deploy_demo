#!/bin/bash

# puppet
sudo curl https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb -o puppetlabs-release.deb
sudo dpkg -i puppetlabs-release.deb

# docker
sudo apt-get remove docker docker-engine
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'

# install everything
sudo apt-get -qq update
sudo apt-get install -yq puppet-agent unzip curl wget vim jq docker-ce
sudo systemctl disable puppet
sudo systemctl stop puppet
sudo /opt/puppetlabs/puppet/bin/puppet module install KyleAnderson-consul --version 2.1.1
sudo /opt/puppetlabs/puppet/bin/puppet module install dudemcbacon-nomad --version 0.0.3
