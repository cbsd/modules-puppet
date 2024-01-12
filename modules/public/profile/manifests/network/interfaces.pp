class profile::network::interfaces {

  case $::osfamily {
    /(Open|Free)BSD/: {
      include bsd::network

      # Manage physical interfaces
      $interfaces = hiera_hash('bsd::network::interface', {})
      create_resources('bsd::network::interface', $interfaces)
    }
  }
}

