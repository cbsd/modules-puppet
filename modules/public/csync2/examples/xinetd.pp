class { 'csync2':
  ensure => stopped,
  enable => false,
}

file { '/etc/xinetd.d/csync2':
  ensure  => file,
  content => "service csync2
{
	flags		= REUSE
	socket_type	= stream
	wait		= no
	user		= root
	group		= root
	server		= ${::csync2::globals::csync2_bin}
	server_args	= -i -l
	#log_on_failure	+= USERID
	disable		= no
	# only_from	= 192.168.199.3 192.168.199.4
}",
  owner   => 'root',
  mode    => '0644',
}

package { 'xinetd':
  ensure => installed,
  before => Service['xinetd'],
}

service { 'xinetd':
  ensure    => running,
  enable    => true,
  subscribe => File['/etc/xinetd.d/csync2'],
}
