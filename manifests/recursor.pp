#
# = Class: pdns::recursor
#
# This class installs and manages pdns server
#
#
# == Parameters
#
# Refer to https://github.com/stdmod for official documentation
# on the stdmod parameters used
#
class pdns::recursor (

  $package_name             = pdns::params::recursor_package_name,
  $package_ensure           = 'present',

  $service_name             = pdns::params::recursor_service_name,
  $service_ensure           = 'running',
  $service_enable           = true,

  $config_file_path         = pdns::params::recursor_config_file_path,
  $config_file_owner        = pdns::params::recursor_config_file_owner,
  $config_file_group        = pdns::params::recursor_config_file_group,
  $config_file_mode         = pdns::params::recursor_config_file_mode,
  $config_file_require      = 'Package[pdns::recursor]',
  $config_file_notify       = 'Service[pdns::recursor]',
  $config_file_source       = undef,
  $config_file_template     = undef,
  $config_file_content      = undef,
  $config_file_options_hash = { },

  $config_dir_path          = pdns::params::recursor_config_dir_path,
  $config_dir_owner         = pdns::params::recursor_config_dir_owner,
  $config_dir_group         = pdns::params::recursor_config_dir_group,
  $config_dir_mode          = pdns::params::recursor_config_dir_mode,
  $config_dir_source        = undef,
  $config_dir_purge         = false,
  $config_dir_recurse       = true,

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
  validate_bool($service_enable)
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
  if $pdns::recursor::dependency_class {
    include $pdns::recursor::dependency_class
  }

  # Resources managed
  if $pdns::recursor::package_name {
    package { 'pdns::recursor':
      ensure => $pdns::recursor::package_ensure,
      name   => $pdns::recursor::package_name,
    }
  }

  if $pdns::recursor::config_file_path {
    file { 'recursor.conf':
      ensure  => $pdns::recursor::config_file_ensure,
      path    => $pdns::recursor::config_file_path,
      mode    => $pdns::recursor::config_file_mode,
      owner   => $pdns::recursor::config_file_owner,
      group   => $pdns::recursor::config_file_group,
      source  => $pdns::recursor::config_file_source,
      content => $pdns::recursor::manage_config_file_content,
      notify  => $pdns::recursor::manage_config_file_notify,
      require => $pdns::recursor::config_file_require,
    }
  }

  if $pdns::recursor::config_dir_source {
    file { 'recursor.dir':
      ensure  => $pdns::recursor::config_dir_ensure,
      path    => $pdns::recursor::config_dir_path,
      mode    => $pdns::recursor::config_dir_mode,
      owner   => $pdns::recursor::config_dir_owner,
      group   => $pdns::recursor::config_dir_group,
      source  => $pdns::recursor::config_dir_source,
      recurse => $pdns::recursor::config_dir_recurse,
      purge   => $pdns::recursor::config_dir_purge,
      force   => $pdns::recursor::config_dir_purge,
      notify  => $pdns::recursor::manage_config_file_notify,
      require => $pdns::recursor::config_file_require,
    }
  }

  if $pdns::recursor::service_name {
    service { 'pdns::recursor':
      ensure => $pdns::recursor::manage_service_ensure,
      name   => $pdns::recursor::service_name,
      enable => $pdns::recursor::manage_service_enable,
    }
  }

  # Extra classes
  if $conf_hash {
    create_resources('pdns::conf', $conf_hash)
  }

  if $pdns::recursor::my_class {
    include $pdns::recursor::my_class
  }

  if $pdns::recursor::monitor_class {
    class { $pdns::recursor::monitor_class:
      options_hash => $pdns::recursor::monitor_options_hash,
      scope_hash   => {}, # TODO: Find a good way to inject class' scope
    }
  }

  if $pdns::recursor::firewall_class {
    class { $pdns::recursor::firewall_class:
      options_hash => $pdns::recursor::firewall_options_hash,
      scope_hash   => {},
    }
  }
}
