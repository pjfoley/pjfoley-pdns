#
# = Class: pdns::backend::bind
#
# This class installs and manages pdns server
#
#
# == Parameters
#
# Refer to https://github.com/stdmod for official documentation
# on the stdmod parameters used
#
class pdns::backend::bind (

  $config_file_name         = undef,
  $config_file_owner        = $pdns::params::server_config_file_owner,
  $config_file_group        = $pdns::params::server_config_file_group,
  $config_file_mode         = $pdns::params::server_config_file_mode,
  $config_file_require      = 'Package[pdns::server]',
  $config_file_notify       = 'class_default',
  $config_file_source       = undef,
  $config_file_template     = undef,
  $config_file_content      = undef,
  $config_file_ensure       = present,
  $config_file_options_hash = { },

  $config_dir_path          = undef,
  $config_dir_owner         = $pdns::params::server_config_dir_owner,
  $config_dir_group         = $pdns::params::server_config_dir_group,
  $config_dir_mode          = $pdns::params::server_config_dir_mode,
  $config_dir_source        = undef,
  $config_dir_purge         = false,
  $config_dir_recurse       = true,
  $config_dir_ensure        = directory,

  $conf_hash                = undef,

  $dependency_class         = undef,
  $my_class                 = undef,

  $monitor_class            = undef,
  $monitor_options_hash     = { },

  $firewall_class           = undef,
  $firewall_options_hash    = { },

  $scope_hash_filter        = '(uptime.*|timestamp)',

  $tcp_port                 = undef,
  $udp_port                 = undef,

  ) inherits pdns::params {

  # Class variables validation and management
  validate_absolute_path($config_dir_path)
  validate_bool($config_dir_recurse)
  validate_bool($config_dir_purge)
  validate_string($config_file_owner)
  validate_string($config_file_group)
  validate_string($config_file_mode)
  validate_string($config_dir_owner)
  validate_string($config_dir_group)
  validate_string($config_dir_mode)
  if $config_file_options_hash { validate_hash($config_file_options_hash) }
  if $monitor_options_hash { validate_hash($monitor_options_hash) }
  if $firewall_options_hash { validate_hash($firewall_options_hash) }

  validate_re($config_file_ensure, ['present','absent'], 'Valid values are: present, absent. WARNING: If set to absent the conf file is removed.')

  validate_re($config_dir_ensure, ['directory','absent'], 'Valid values are: present, absent. WARNING: If set to absent the conf file is removed.')

  $manage_config_file_content = default_content($config_file_content, $config_file_template)

  $manage_config_file_notify  = $config_file_notify ? {
    'class_default' => 'Service[pdns::server]',
    ''              => undef,
    default         => $config_file_notify,
  }

  if $config_dir_ensure == 'absent' {
    $config_dir_ensure     = 'absent'
    $config_file_ensure    = 'absent'
  } else {
    $config_dir_ensure     = 'directory'
    $config_file_ensure    = 'present'
  }

  # Dependency class
  if $pdns::backend::bind::dependency_class {
    include $pdns::backend::bind::dependency_class
  }

  if $pdns::backend::bind::config_dir_source {
    file { 'bind.dir':
      ensure  => $pdns::backend::bind::config_dir_ensure,
      path    => $pdns::backend::bind::config_dir_path,
      mode    => $pdns::backend::bind::config_dir_mode,
      owner   => $pdns::backend::bind::config_dir_owner,
      group   => $pdns::backend::bind::config_dir_group,
      source  => $pdns::backend::bind::config_dir_source,
      recurse => $pdns::backend::bind::config_dir_recurse,
      purge   => $pdns::backend::bind::config_dir_purge,
      force   => $pdns::backend::bind::config_dir_purge,
      notify  => $pdns::backend::bind::manage_config_file_notify,
      require => $pdns::backend::bind::config_file_require,
    }
  }
  else
  {
    file { 'bind.dir':
      ensure  => $pdns::backend::bind::config_dir_ensure,
      path    => $pdns::backend::bind::config_dir_path,
      mode    => $pdns::backend::bind::config_dir_mode,
      owner   => $pdns::backend::bind::config_dir_owner,
      group   => $pdns::backend::bind::config_dir_group,
      purge   => $pdns::backend::bind::config_dir_purge,
      force   => $pdns::backend::bind::config_dir_purge,
      notify  => $pdns::backend::bind::manage_config_file_notify,
      require => $pdns::backend::bind::config_file_require,
    }
  }

  if $pdns::backend::bind::config_file_path {
    file { 'bind.conf':
      ensure  => $pdns::backend::bind::config_file_ensure,
      path    => $pdns::backend::bind::config_file_path,
      mode    => $pdns::backend::bind::config_file_mode,
      owner   => $pdns::backend::bind::config_file_owner,
      group   => $pdns::backend::bind::config_file_group,
      source  => $pdns::backend::bind::config_file_source,
      content => $pdns::backend::bind::manage_config_file_content,
      notify  => $pdns::backend::bind::manage_config_file_notify,
      require => [ $pdns::backend::bind::config_file_require, File['bind.dir'] ],
    }
  }

  # Extra classes
  if $conf_hash {
    create_resources('pdns::conf', $conf_hash)
  }

  if $pdns::backend::bind::my_class {
    include $pdns::backend::bind::my_class
  }

  if $pdns::backend::bind::monitor_class {
    class { $pdns::backend::bind::monitor_class:
      options_hash => $pdns::backend::bind::monitor_options_hash,
      scope_hash   => {}, # TODO: Find a good way to inject class' scope
    }
  }

  if $pdns::backend::bind::firewall_class {
    class { $pdns::backend::bind::firewall_class:
      options_hash => $pdns::backend::bind::firewall_options_hash,
      scope_hash   => {},
    }
  }
}
