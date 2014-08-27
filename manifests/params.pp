# Class: pdns::params
#
# Defines all the variables used in the module.
#
class pdns::params {

  ## PowerDNS Server settings
  $server_package_name = $::osfamily ? {
    'Debian' => 'pdns-server',
    default  => 'pdns',
  }

  $server_service_name = $::osfamily ? {
    default => 'pdns',
  }

  $server_service_process_user = $::osfamily ? {
    default => 'pdns',
  }

  $server_service_process_group = $::osfamily ? {
    default => 'pdns',
  }

  $server_config_file_path = $::osfamily ? {
    'Debian' => '/etc/powerdns/pdns.conf',
    default  => '/etc/pdns/pdns.conf',
  }

  $server_config_file_mode = $::osfamily ? {
    default => '0444',
  }

  $server_config_file_owner = $::osfamily ? {
    default => 'pdns',
  }

  $server_config_file_group = $::osfamily ? {
    default => 'pdns',
  }

  $server_config_dir_path = $::osfamily ? {
    'Debian' => '/etc/powerdns/pdns.d',
    default  => '/etc/pdns/pdns.d',
  }

  $server_config_dir_mode = $::osfamily ? {
    default => '0555',
  }

  $server_config_dir_owner = $::osfamily ? {
    default => 'pdns',
  }

  $server_config_dir_group = $::osfamily ? {
    default => 'pdns',
  }

  ## PowerDNS Recursor settings
  $recursor_package_name = $::osfamily ? {
    default  => 'pdns-recursor',
  }

  $recursor_service_name = $::osfamily ? {
    default => 'pdns-recursor',
  }

  $recursor_config_file_path = $::osfamily ? {
    'Debian' => '/etc/powerdns/recursor.conf',
    default  => '/etc/pdns-recursor/recursor.conf',
  }

  $recursor_config_file_mode = $::osfamily ? {
    default => '0444',
  }

  $recursor_config_file_owner = $::osfamily ? {
    default => 'pdns',
  }

  $recursor_config_file_group = $::osfamily ? {
    default => 'pdns',
  }

  $recursor_config_dir_path = $::osfamily ? {
    'Debian' => '/etc/powerdns/pdns.d',
    default  => '/etc/pdns-recursor/pdns.d',
  }

  $recursor_config_dir_mode = $::osfamily ? {
    default => '0555',
  }

  $recursor_config_dir_owner = $::osfamily ? {
    default => 'pdns',
  }

  $recursor_config_dir_group = $::osfamily ? {
    default => 'pdns',
  }
  case $::osfamily {
    'Debian','RedHat','Amazon': { }
    default: {
      fail("${::operatingsystem} not supported. Review params.pp for extending support.")
    }
  }
}
