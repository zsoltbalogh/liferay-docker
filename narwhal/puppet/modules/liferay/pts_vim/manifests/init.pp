class pts_vim {

  package { 'vim':
    ensure => latest
  }

  file { '/etc/vim/vimrc.local':
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => "puppet:///modules/${module_name}/etc/vim/vimrc.local",
  }

}
