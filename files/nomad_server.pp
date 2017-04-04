$conf_dir = '/etc/nomad.d'
$sysconfig = '/etc/sysconfig'
$addr = $::facts['networking']['interfaces']['enp0s8']['ip']

file_line{"add puppet path":
    path => '/etc/environment',
    line => 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/puppetlabs/puppet/bin"',
    match   => "^PATH.*$",
    replace => true,
}

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
