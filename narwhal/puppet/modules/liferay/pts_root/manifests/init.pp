class pts_root {

  file { '/root/.bash_profile':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp("${module_name}/root/.bash_profile.epp")
  }

}
