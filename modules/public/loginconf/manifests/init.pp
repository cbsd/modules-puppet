class loginconf (
    $charset="UTF-8",
    $lang="C.UTF-8" ) {

    file { "/etc/login.conf":
        ensure  => present,
        content => template("$module_name/login.conf.erb"),
        mode => '0644',
    }

    exec {"/usr/bin/cap_mkdb /etc/login.conf":
        subscribe   => File['/etc/login.conf'],
        refreshonly => true,
    }

    Exec { environment => [ "LANG=${lang}" ] }

}
