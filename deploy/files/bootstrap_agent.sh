#!/bin/bash

cat > /tmp/consul_agent.pp << "EOF"
$conf_dir = '/etc/consul.d'

file{ $conf_dir:
  ensure => directory,
}

class { '::consul':
  config_dir    => "${conf_dir}/agent",
  pretty_config => true,
  version       => '0.7.5',
    config_hash => {
      'data_dir'       => '/opt/consul',
      'datacenter'     => 'local',
      'log_level'      => 'DEBUG',
      'retry_join_ec2' => {
        'tag_key'   => 'Role',
        'tag_value' => 'server'
      },
  },
  require => File[$conf_dir],
}
"EOF"

cat > /tmp/nomad_agent.pp << "EOF"
$conf_dir = '/etc/nomad.d'
$sysconfig = '/etc/sysconfig' #module doesn't support 16.04
$addr = $::facts['ipaddress']

file_line{"add nomad addr":
    path => '/etc/environment',
    line => "NOMAD_ADDR=http://${$addr}:4646",
}

file{ $conf_dir:
  ensure => directory,
}

file{ $sysconfig:
  ensure => directory,
}

class { '::nomad':
  version       => '0.5.6',
  pretty_config => true,
  config_dir    => "${conf_dir}/agent",
  config_hash   => {
    'datacenter' => 'local',
    'log_level'  => 'DEBUG',
    'bind_addr'  => $addr,
    'data_dir'   => '/opt/nomad',
    'client'     => {
      'enabled'    => true,
      'options'    => {
        'driver.raw_exec.enable' => '1'
      }
      #'chroot_env' => $chroot_env
    }
  },
  require => File[$conf_dir],
}
"EOF"

sudo /opt/puppetlabs/bin/puppet apply /tmp/consul_agent.pp
sudo /opt/puppetlabs/bin/puppet apply /tmp/nomad_agent.pp
