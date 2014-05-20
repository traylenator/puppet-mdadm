# == Class: mdadm
#
# Please refer to https://github.com/jhoblitt/puppet-mdadm#usage for parameter
# documentation.
#
class mdadm(
  $config_file_manage  = $::mdadm::params::config_file_manage,
  $config_file_options = {},
  $service_force       = false,
  $service_ensure      = 'running',
  $service_enable      = true,
  $raid_check_manage   = true,
  $raid_check_options  = {},
) inherits mdadm::params {
  validate_bool($config_file_manage)
  validate_hash($config_file_options)
  validate_bool($service_force)
  validate_re($service_ensure, '^running$|^stopped$')
  validate_bool($service_enable)
  validate_bool($raid_check_manage)
  validate_hash($raid_check_options)

  if $service_force {
    $use_service_ensure = $service_ensure
    $use_service_enable = $service_enable
  } elsif $::mdadm_arrays {
    $use_service_ensure = 'running'
    $use_service_enable = true
  } else {
    $use_service_ensure = 'stopped'
    $use_service_enable = false
  }

  package { $mdadm::params::mdadm_package:
    ensure => present,
  }

  if $config_file_manage {
    Package[$mdadm::params::mdadm_package] ->
    class { 'mdadm::config':
      options => $config_file_options,
    } ->
    Class['mdadm::mdmonitor']
  }

  class { 'mdadm::mdmonitor':
    ensure => $use_service_ensure,
    enable => $use_service_enable,
  }

  if $raid_check_manage {
    Class['mdadm::mdmonitor'] ->
    class { 'mdadm::raid_check':
      options => $raid_check_options,
    } ->
    Anchor['mdadm::end']
  }

  anchor { 'mdadm::begin': } ->
  Package[$mdadm::params::mdadm_package] ->
  Class['mdadm::mdmonitor'] ->
  anchor { 'mdadm::end': }
}
