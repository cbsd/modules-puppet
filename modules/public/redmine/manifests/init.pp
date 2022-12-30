class redmine(
  $db_name         = "redmine",
  $db_user         = "redmine",
  $db_password     = "redmine_password",
  $redmine_port    = 3000,
  $redmine_package = "redmine50",
) {

  ensure_resource('package', $redmine::redmine_package, {'ensure' => 'present'})

  file { "/usr/local/www/redmine/config/database.yml":
    mode    => '0444',
    ensure  => present,
    content => template("${module_name}/database.yml.erb"),
    owner   => "www",
  } -> file { "/usr/local/etc/rc.d/redmine":
    mode => '0555',
    ensure  => present,
    content => template("${module_name}/redmine.erb"),
    #notify  => Service['redmine'],
  } -> file { "/usr/local/bin/redmine-helper.sh":
    mode => '0555',
    ensure  => present,
    content => template("${module_name}/redmine-helper.sh.erb"),
  } -> service { 'redmine':
    #ensure => running,
    enable => true,
  } -> exec { 'redmine-helper.sh':
      command => "/usr/local/bin/redmine-helper.sh",
  }

}
