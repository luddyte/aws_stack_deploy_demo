$conf_dir = '/etc/nomad.d'
$sysconfig = '/etc/sysconfig'
$addr = $::facts['networking']['interfaces']['enp0s8']['ip']

# added to support exec, but had to use raw_exec so this isn't currently referenced
$chroot_env = {
  '/bin'             => '/bin',
  '/etc'             => '/etc',
  '/lib'             => '/lib',
  '/lib32'           => '/lib32',
  '/lib64'           => '/lib64',
  '/run/resolveconf' => '/run/resolveconf',
  '/sbin'            => '/sbin',
  '/usr'             => '/usr',
  '/var/lib/mongodb' => '/var/lib/mongodb',
  '/var/log/mongodb' => '/var/log/mongodb'
}

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
  config_dir    => "${conf_dir}/agent",
  config_hash   => {
    'datacenter' => 'local',
    'log_level'  => 'INFO',
    'bind_addr'  => $::facts['networking']['interfaces']['enp0s8']['ip'],
    'data_dir'   => '/opt/nomad',
    'client'     => {
      'enabled'    => true,
      'servers'    => [
        'server:4647',
      ],
      'options'    => {
        'driver.raw_exec.enable' => '1'
      }
      #'chroot_env' => $chroot_env
    }
  },
  require => File[$conf_dir],
}
