#!/bin/bash
cat >/tmp/consul_server.pp << "EOF"
$conf_dir = '/etc/consul.d'

file{ $conf_dir:
  ensure => directory,
}

class { '::consul':
  config_dir    => "${conf_dir}/server",
  pretty_config => true,
  version       => '0.7.5',
  config_hash => {
    'bootstrap_expect' => 1,
    'data_dir'         => '/opt/consul',
    'datacenter'       => 'local',
    'log_level'        => 'DEBUG',
    'node_name'        => 'server',
    'server'           => true,
    'ui_dir'           => '/opt/consul/ui',
    'client_addr'      => '0.0.0.0'
  },
  require => File[$conf_dir],
}
EOF

cat >/tmp/nomad_server.pp << "EOF"
$conf_dir = '/etc/nomad.d'
$sysconfig = '/etc/sysconfig'

file_line{"add nomad addr":
    path => '/etc/environment',
    line => "NOMAD_ADDR=http://${$::facts['ipaddress']}:4646",
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
  config_dir    => "${conf_dir}/server",
  config_hash   => {
    'datacenter' => 'local',
    'log_level'  => 'INFO',
    'bind_addr'  => $addr,
    'data_dir'   => '/opt/nomad',
    'server'     => {
      'enabled'          => true,
      'bootstrap_expect' => 1,
    }
  },
  require => File[$conf_dir],
}
"EOF"

sudo /opt/puppetlabs/bin/puppet apply /tmp/consul_server.pp
sudo /opt/puppetlabs/bin/puppet apply /tmp/nomad_server.pp
