# manage PowerDNS+backend + UI all-on-one
# If supermaster is specified, all new zones will be added automatically to the slave when notified by the master.
# in slave: 
#  INSERT INTO supermasters (ip, nameserver, account) VALUES ('10.0.0.2', 'ns2.my.domain', '');
# on master
# dnsutil-add-domain.sh my.domain
# ./pdnsutil-add-domain.sh my.domain
# ./pdnsutil-add-record.sh my.domain host01.my.domain A 300 10.0.0.1
# ./pdnsutil-add-record.sh my.domain ns2.my.domain A 300 10.0.0.3
# in shell: 
#  pdns_control notify my.domain
class profiles::services::powerdns (
  String  $backend                      = 'sqlite',
  Boolean $backend_install              = true,
  Boolean $powerdnsadmin_install        = false,
  String  $powerdnsadmin_config_dir     = '/usr/local/etc/powerdnsadmin',
  String  $powerdnsadmin_config_file    = "${powerdnsadmin_config_dir}/default_config.py",
  String  $master                       = 'yes',
  String  $slave                        = 'no',
  String  $superslave                   = 'no',
  Optional[String[1]] $masterhost        = undef,
  Optional[String[1]] $slavehost        = undef,
  Optional[String[1]] $db_root_password = undef,
  Optional[String[1]] $db_password      = undef,
  Optional[String[1]] $db_name          = 'powerdns',
  Optional[String[1]] $db_username      = 'powerdns',
){

  file { '/root/powerdns':
    ensure  => directory,
    mode    => '0700',
    source  => "puppet:///modules/${module_name}/powerdns",
    owner   => 0,
    group   => 0,
    recurse => true,
  }

  powerdns::config { 'authoritative-api': ensure  => present, setting => 'api', value => 'yes', type => 'authoritative', }
  powerdns::config { 'version-string': ensure  => present, setting => 'version-string', value   => 'better than nothing', }
  powerdns::config { 'webserver': ensure  => present, setting => 'webserver', value   => 'yes', }
  powerdns::config { 'webserver-address': ensure  => present, setting => 'webserver-address', value   => '0.0.0.0', }
  powerdns::config { 'webserver-port': ensure  => present, setting => 'webserver-port', value   => '8081', }

  #powerdns::config { 'allow-recursion': ensure  => present, setting => 'allow-recursion', value   => '0.0.0.0/0', }
  powerdns::config { 'cache-ttl': ensure  => present, setting => 'cache-ttl', value   => '20', }
  #powerdns::config { 'default-soa-name': ensure  => present, setting => 'default-soa-name', value   => 'ns1.my.domain', }
  powerdns::config { 'default-ttl': ensure  => present, setting => 'default-ttl', value   => '3600', }
  #powerdns::config { 'launch': ensure  => present, setting => 'gpgsql', value   => 'gpgsql,remote', }
  #powerdns::config { 'remote-connection-string': ensure  => present, setting => 'remote-connection-string', value   => 'remote-connection-string=pipe:command=/opt/pdns-hashbang.sh,timeout=2000', }
  #powerdns::config { 'webserver-allow-from': ensure  => present, setting => 'webserver-allow-from', value   => '127.0.0.0/8,10.0.0.0/24', }
  # for test only
  powerdns::config { 'webserver-allow-from': ensure  => present, setting => 'webserver-allow-from', value   => '0.0.0.0/0', }
  powerdns::config { 'api-key': ensure  => present, setting => 'api-key', value   => 'test', }
  powerdns::config { 'master': ensure  => present, setting => 'master', value   => "${master}", }
# fallback, e.g also-notify=192.0.2.1,192.168.2.2
#  powerdns::config { 'also-notify': ensure  => present, setting => 'also-notify', value   => '10.0.0.161', }
  powerdns::config { 'authoritative-local-address': type => 'authoritative', setting => 'local-address', value   => '0.0.0.0', }
  powerdns::config { 'authoritative-query-local-address': type => 'authoritative', setting => 'query-local-address', value   => '0.0.0.0', }
  # + IPv6:
  #powerdns::config { 'authoritative-query-local-address': type => 'authoritative', setting => 'query-local-address', value   => '0.0.0.0 ::', }

# slave settings
  powerdns::config { 'slave': ensure  => present, setting => 'slave', value   => "${slave}", }
  powerdns::config { 'superslave': ensure  => present, setting => 'superslave', value   => "${superslave}", }

  if $masterhost {
    powerdns::config { 'slave-cycle-interval': ensure  => present, setting => 'slave-cycle-interval', value   => '60', }
  }

# master host:
  if $slavehost {
    powerdns::config { 'also-notify': ensure  => present, setting => 'also-notify', value   => "${slavehost}", }
    powerdns::config { 'allow-axfr-ips': ensure  => present, setting => 'allow-axfr-ips', value   => "${slavehost}", }
    powerdns::config { 'allow-dnsupdate-from': ensure  => present, setting => 'allow-dnsupdate-from', value   => "${slavehost}", }
    powerdns::config { 'allow-notify-from': ensure  => present, setting => 'allow-notify-from', value   => "${slavehost}", }
    powerdns::config { 'disable-axfr': ensure  => present, setting => 'disable-axfr', value   => 'no', }
  } else {
    powerdns::config { 'disable-axfr': ensure  => present, setting => 'disable-axfr', value   => 'yes', }
  }


  case $backend {
    'sqlite': {
      # SQLite3 backend
      class { 'powerdns':
        backend_install  => $backend_install,
        backend          => $backend,
      }
    }
    'postgresql': {
      if $backend_install {
        assert_type(String[1], $db_root_password) |$expected, $actual| {
          fail("'db_root_password' must be a non-empty string when 'backend_install' == true")
        }
        #class { '::postgresql::server':
        #  postgres_password => $db_root_password,
        #  #service_provider  => 'freebsd',
        #}
        #postgresql::server::pg_hba_rule { 'allow application network to access app database':
        #  description => "Open up PostgreSQL for access from $db_username -> $db_name",
        #  type        => 'host',
        #  database    => $db_name,
        #  user        => $db_username,
        #  address     => '0.0.0.0/0',
        #  auth_method => 'md5',
        #}
        class { 'powerdns':
          backend_install  => $backend_install,
          backend          => $backend,
          db_root_password => $db_root_password,
          db_password      => $db_password,
          #require          => Postgresql::Server::Db[$db_name],
        }
      }
    }
    'mysql': {
      if $backend_install {
        assert_type(String[1], $db_root_password) |$expected, $actual| {
          fail("'db_root_password' must be a non-empty string when 'backend_install' == true")
      }

        $override_options = {
          'mysqld'      => {
            #'skip-networking',
            'socket'    => '/tmp/mysql.sock',
          },
          'client'      => {
            'socket'    => '/tmp/mysql.sock',
          },
          'mysqld_safe' => {
            'socket'    => '/tmp/mysql.sock',
          }
        }

        class { '::mysql::server':
          root_password      => $::powerdns::db_root_password,
          service_manage     => true,
          restart            => true,
          override_options   => $override_options,
          create_root_my_cnf => true,
        }
        mysql::db { $db_name:
          user     => $db_username,
          password => $db_password,
          #host     => "127.0.0.1",
          host     => "%",
          grant    => [ 'ALL' ],
          sql      => '/usr/local/share/doc/powerdns/schema.mysql.sql',
        }
#        mysql_grant { "${db_username}@${ipaddress}/${db_name}.*":
#          user       => "$db_username@${ipaddress}",
#          table      => "${db_name}.*",
#          privileges => ['ALL'],
#        }
#        mysql_grant { "${db_username}@localhost/${db_name}.*":
#          user       => "$db_username@localhost",
#          table      => "${db_name}.*",
#          privileges => ['ALL'],
#        }
        class { 'powerdns':
          backend_create_tables => false,
          backend_install       => $backend_install,
          backend               => $backend,
          db_root_password      => $db_root_password,
          db_password           => $db_password,
        }
      }
    }
    default: {
      fail("${backend} backend is not supported yet.")
    }
  }

  if $powerdnsadmin_install {
    file { $powerdnsadmin_config_dir:
      ensure => directory,
      mode   => '0650',
    }
    file { $powerdnsadmin_config_file:
     ensure  => present,
     mode    => '0640',
     content => template("${module_name}/default_config.py.erb"),
     owner   => 0,
     group   => 0,
    }
    exec { "powerdnsadmin_install":
      command => "/root/powerdns/poweradmin_install.sh",
      # default 300 sec too small for install
      timeout => 1500,
      onlyif  => "/usr/bin/env test ! -r /usr/local/etc/rc.d/powerdnsadmin",
    }
    # ->
    # service enable=true not create /etc/rc.conf.d/powerdnsadmin, why?
#    file { '/etc/rc.conf.d/powerdnsadmin':
#      content => 'powerdnsadmin_enable="YES"',
#      ensure  => present,
#    } -> service { 'powerdnsadmin':
#      ensure   => running,
#      enable   => true,
#      provider => 'freebsd',
#    }
  } else {
    exec { "powerdnsadmin_install":
      command => "/root/powerdns/poweradmin_install.sh",
      onlyif  => "/usr/bin/env test ! -r /root/powerdnsadmin/buildok",
    }
  }
}
