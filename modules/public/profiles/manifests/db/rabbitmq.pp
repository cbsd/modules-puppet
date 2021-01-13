class profiles::db::rabbitmq (
  Hash $globals = {},
  #Hash[String, Hash[String, Variant[String, Boolean]]] $instance = {},
  Hash $instance = {},
){

  #? not in mod
  file { '/var/db/rabbitmq':
    ensure => directory,
    owner => 'rabbitmq',
    group => 'rabbitmq',
  }

  class { '::rabbitmq':
    * => $globals,
  }

  create_resources('::rabbitmq::instance', $instance)
}
