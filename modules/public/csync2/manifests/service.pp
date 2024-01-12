# @summary
#   This class handles the Csync2 service. By default the service will
#   start on boot and will be restarted if stopped.
#
# @api private
#
class csync2::service {
  assert_private()

  $service_name   = $csync2::globals::service_name
  $manage_service = $csync2::manage_service
  $ensure         = $csync2::ensure
  $enable         = $csync2::enable

  if $manage_service {
    service { $service_name:
      ensure => $ensure,
      enable => $enable,
    }
  }
}
