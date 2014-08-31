#
# = Class: pdns::server
#
# This class installs and manages pdns server
#
#
# == Parameters
#
# Refer to https://github.com/stdmod for official documentation
# on the stdmod parameters used
#
class pdns::server (

  $package_name             = $pdns::params::server_package_name,
  $package_ensure           = 'present',

  $service_name             = $pdns::params::server_service_name,
  $service_process_user     = $pdns::params::server_service_process_user,
  $service_process_group    = $pdns::params::server_service_process_group,
  $service_ensure           = 'running',
  $service_enable           = true,

  $config_file_path         = $pdns::params::server_config_file_path,
  $config_file_owner        = $pdns::params::server_config_file_owner,
  $config_file_group        = $pdns::params::server_config_file_group,
  $config_file_mode         = $pdns::params::server_config_file_mode,
  $config_file_require      = 'Package[pdns::server]',
  $config_file_notify       = 'Service[pdns::server]',
  $config_file_source       = undef,
  $config_file_template     = undef,
  $config_file_content      = undef,
  $config_file_options_hash = { },

  $config_dir_path          = $pdns::params::server_config_dir_path,
  $config_dir_owner         = $pdns::params::server_config_dir_owner,
  $config_dir_group         = $pdns::params::server_config_dir_group,
  $config_dir_mode          = $pdns::params::server_config_dir_mode,
  $config_dir_source        = undef,
  $config_dir_purge         = false,
  $config_dir_recurse       = true,

  $fragments_dir_path       = $pdns::params::server_config_fragments_dir_path,
  $fragments_dir_owner      = $pdns::params::server_config_dir_owner,
  $fragments_dir_group      = $pdns::params::server_config_dir_group,
  $fragments_dir_mode       = $pdns::params::server_config_dir_mode,
  $fragments_dir_source     = undef,
  $fragments_dir_purge      = false,
  $fragments_dir_recurse    = true,

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
  validate_absolute_path($config_file_path)
  validate_absolute_path($fragments_dir_path)
  validate_bool($service_enable)
  validate_bool($config_dir_recurse)
  validate_bool($config_dir_purge)
  validate_bool($fragments_dir_recurse)
  validate_bool($fragments_dir_purge)
  validate_string($config_file_owner)
  validate_string($config_file_group)
  validate_string($config_file_mode)
  validate_string($config_dir_owner)
  validate_string($config_dir_group)
  validate_string($config_dir_mode)
  validate_string($fragments_dir_owner)
  validate_string($fragments_dir_group)
  validate_string($fragments_dir_mode)
  if $config_file_options_hash { validate_hash($config_file_options_hash) }
  if $monitor_options_hash { validate_hash($monitor_options_hash) }
  if $firewall_options_hash { validate_hash($firewall_options_hash) }

  $manage_config_file_content = default_content($config_file_content, $config_file_template)

  $manage_config_file_notify  = $config_file_notify ? {
    'class_default' => 'Service[pdns::server]',
    ''              => undef,
    default         => $config_file_notify,
  }

  if $package_ensure == 'absent' {
    $manage_service_enable = undef
    $manage_service_ensure = 'stopped'
    $config_dir_ensure     = 'absent'
    $config_file_ensure    = 'absent'
  } else {
    $manage_service_enable = $service_enable
    $manage_service_ensure = $service_ensure
    $config_dir_ensure     = 'directory'
    $config_file_ensure    = 'present'
  }

  # Dependency class
  if $pdns::server::dependency_class {
    include $pdns::server::dependency_class
  }

  # Resources managed
  if $pdns::server::package_name {
    package { 'pdns::server':
      ensure => $pdns::server::package_ensure,
      name   => $pdns::server::package_name,
    }
  }

  if $pdns::server::config_dir_source {
    file { 'pdns.dir':
      ensure  => $pdns::server::config_dir_ensure,
      path    => $pdns::server::config_dir_path,
      mode    => $pdns::server::config_dir_mode,
      owner   => $pdns::server::config_dir_owner,
      group   => $pdns::server::config_dir_group,
      source  => $pdns::server::config_dir_source,
      recurse => $pdns::server::config_dir_recurse,
      purge   => $pdns::server::config_dir_purge,
      force   => $pdns::server::config_dir_purge,
      notify  => $pdns::server::manage_config_file_notify,
      require => $pdns::server::config_file_require,
    }
  }
  else
  {
    file { 'pdns.dir':
      ensure  => $pdns::server::config_dir_ensure,
      path    => $pdns::server::config_dir_path,
      mode    => $pdns::server::config_dir_mode,
      owner   => $pdns::server::config_dir_owner,
      group   => $pdns::server::config_dir_group,
      purge   => $pdns::server::config_dir_purge,
      force   => $pdns::server::config_dir_purge,
      notify  => $pdns::server::manage_config_file_notify,
      require => $pdns::server::config_file_require,
    }
    file { 'pdns.frgmnts.dir':
      ensure  => $pdns::server::fragments_dir_ensure,
      path    => $pdns::server::fragments_dir_path,
      mode    => $pdns::server::fragments_dir_mode,
      owner   => $pdns::server::fragments_dir_owner,
      group   => $pdns::server::fragments_dir_group,
      source  => $pdns::server::fragments_dir_source,
      recurse => $pdns::server::fragments_dir_recurse,
      purge   => $pdns::server::fragments_dir_purge,
      force   => $pdns::server::fragments_dir_purge,
      notify  => $pdns::server::manage_config_file_notify,
      require => [ $pdns::server::config_file_require, File['pdns.dir'] ],
    }
  }

  if $pdns::server::config_file_path {
    file { 'pdns.conf':
      ensure  => $pdns::server::config_file_ensure,
      path    => $pdns::server::config_file_path,
      mode    => $pdns::server::config_file_mode,
      owner   => $pdns::server::config_file_owner,
      group   => $pdns::server::config_file_group,
      source  => $pdns::server::config_file_source,
      content => $pdns::server::manage_config_file_content,
      notify  => $pdns::server::manage_config_file_notify,
      require => [ $pdns::server::config_file_require, File['pdns.dir'] ],
    }
  }

  if $pdns::server::service_name {
    service { 'pdns::server':
      ensure => $pdns::server::manage_service_ensure,
      name   => $pdns::server::service_name,
      enable => $pdns::server::manage_service_enable,
    }
  }

  # Extra classes
  if $conf_hash {
    create_resources('pdns::conf', $conf_hash)
  }

  if $pdns::server::my_class {
    include $pdns::server::my_class
  }

  if $pdns::server::monitor_class {
    class { $pdns::server::monitor_class:
      options_hash => $pdns::server::monitor_options_hash,
      scope_hash   => {}, # TODO: Find a good way to inject class' scope
    }
  }

  if $pdns::server::firewall_class {
    class { $pdns::server::firewall_class:
      options_hash => $pdns::server::firewall_options_hash,
      scope_hash   => {},
    }
  }
}
