class pts_motd {

  file { '/usr/local/bin/update-motd.d':
    ensure  => 'directory',
    recurse => 'true',
    purge   => 'true',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => "puppet:///modules/${module_name}/usr/local/bin/update-motd.d/",
  }

  file { '/etc/cron.d/update-motd':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "*/5 * * * * root bash -c \"run-parts -u 002 /usr/local/bin/update-motd.d > /etc/motd; chmod 644 /etc/motd\"\n",
  }

  package { 'update-notifier-common':
    ensure => latest
  }

  systemd::timer { 'motd-news.timer':
    ensure => absent,
    active => false,
    enable => false,
  }

  systemd::unit_file { 'motd-news.service':
    ensure => absent
  }
}
