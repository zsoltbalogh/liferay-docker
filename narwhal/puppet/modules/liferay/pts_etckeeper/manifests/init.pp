class pts_etckeeper {

  package { 'etckeeper':
    ensure => latest
  }

  file { '/etc/etckeeper/etckeeper.conf':
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => "puppet:///modules/${module_name}/etc/etckeeper/etckeeper.conf",
    require => Package['etckeeper'],
  }
}
