# @summary
#   This class exists to manage general configuration files needed by Csync2 to run.
#
# @api private
#
class csync2::config {
  assert_private()

  $ssl_cert_path  = $csync2::globals::ssl_cert_path
  $ssl_key_path   = $csync2::globals::ssl_key_path
  $csync2_bin     = $csync2::globals::csync2_bin
  $ssl_cert       = $csync2::ssl_cert
  $ssl_key        = $csync2::ssl_key
  $port           = $csync2::port
  $service_opts   = $csync2::globals::service_opts

  if $ssl_key and $ssl_cert {
    file {
      default:
        ensure => file,
        owner  => 'root',
        group  => 'root';
      $ssl_cert_path:
        content => $ssl_cert,
        mode    => '0644';
      $ssl_key_path:
        content => $ssl_key,
        mode    => '0600';
    }
  }

  systemd::unit_file { 'csync2@.service':
    content => template('csync2/service_unit.erb'),
  }

  systemd::unit_file { 'csync2.socket':
    content => template('csync2/service_socket.erb'),
  }
}
