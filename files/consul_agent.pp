$conf_dir = '/etc/consul.d'
$addr = $::facts['networking']['interfaces']['enp0s8']['ip']

file{ $conf_dir:
  ensure => directory,
}

class { '::consul':
  config_dir    => "${conf_dir}/agent",
  pretty_config => true,
  version       => '0.7.5',
    config_hash => {
      'bind_addr'      => $addr,
      # shouldn't have to set this, but testing to work around potential vagrant issue
      # docs say consul should use the bind_addr for adverising if it's not specified,
      # but on my vagrant test system it was adverising the addr of enp0s3 not s8.  Bug?
      'advertise_addr' => $addr,
      'data_dir'       => '/opt/consul',
      'datacenter'     => 'local',
      'log_level'      => 'DEBUG',
      'retry_join'     => ['server'],
  },
  require => File[$conf_dir],
}
