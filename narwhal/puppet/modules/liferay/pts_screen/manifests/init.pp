class pts_screen {

  package { 'screen':
    ensure => latest
  }

  file { '/root/.screenrc':
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => "puppet:///modules/${module_name}/root/.screenrc",
  }
}
