#!/bin/bash

sudo apt-get install -yq mongodb
sudo systemctl disable mongodb
sudo systemctl stop mongodb

cat > /tmp/db.pp << "EOF"
$file = '/etc/nomad.d/agent/config.json'

file_line { "add metadata":
  path  => $file,
  line  => '      "meta" : { "role" :"db" },',
  match => '/client/',
  after => '"client": {'
}
"EOF"

sudo /opt/puppetlabs/puppet/bin/puppet apply /tmp.pp
