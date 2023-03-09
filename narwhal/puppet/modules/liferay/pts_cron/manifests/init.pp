class pts_cron {

  package { 'cron':
    ensure => latest
  }

  file { '/etc/default/cron':
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => "puppet:///modules/${module_name}/etc/default/cron",
  }
}
