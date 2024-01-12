class { 'csync2':
  groups => {
    'cluster' => {
      hosts  => ['node1.example.org', 'node2.example.org'],
      blocks => [{
          'includes' => ['/etc/csync2.cfg'],
      }],
      key    => 'supersecret',
    },
  },
}

csync2::group { 'monitoring':
  hosts  => ['node1.example.org', 'node2.example.org'],
  blocks => [
    {
      'includes' => ['/etc/icinga2/features-available', '/etc/icinga2/features-enabled'],
      'actions'  => [
        {
          'pattern' => ['/etc/icinga2/features-enabled/*'],
          'exec'    => ['systemctl reload icinga2'],
          'logfile' => '/var/log/csync2_action.log',
          'do'      => 'do-local',
        },
      ],
    },
    {
      'includes' => ['/etc/icingaweb2'],
      'excludes' => ['/etc/icingaweb2/modules/director', '/etc/icingaweb2/enabledModules/director'],
    },
  ],
  key    => 'supersecret',
}
