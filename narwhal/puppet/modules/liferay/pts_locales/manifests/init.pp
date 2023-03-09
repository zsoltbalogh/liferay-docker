class pts_locales {

  exec { 'locale-gen':
    command     => '/usr/sbin/locale-gen',
    refreshonly => true,
  }

  file { '/etc/default/locale':
    owner   => root,
    group   => root,
    mode    => '0644',
    content => "LANG=\"en_US.UTF-8\"\n",
  }

  file { '/etc/locale.gen':
    owner   => root,
    group   => root,
    mode    => '0644',
    content => "en_US.UTF-8 UTF-8\n",
    notify  => Exec['locale-gen'],
  }

}
