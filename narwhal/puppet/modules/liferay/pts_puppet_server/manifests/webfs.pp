class 'pts_puppet_server::webfs' {

  package { 'webfs':
    ensure => latest
  }

  service { 'webfs':
    ensure => running,
    require => Package['webfs'],
  }

  file { '/etc/webfsd.conf':
    owner   => root,
    group   => root,
    mode    => '0664',
    source  => "puppet:///modules/${module_name}/etc/webfsd.conf",
    require => Package['webfs'],
    notify  => Service['webfs'],
  }
}
