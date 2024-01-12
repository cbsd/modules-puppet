class profile::network::mybnetwork {



  bsd::network::interface::cloned { 'bridge10':
    ensure => present,
  }

  bsd::network::interface { 'bridge10':
    description => 'Jail Interface',
    addresses   => [ '10.0.10.1/24' ],
  }

}

