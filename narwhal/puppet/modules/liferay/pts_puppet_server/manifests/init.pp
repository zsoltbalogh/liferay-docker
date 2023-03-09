class pts_puppet_server {

  include pts_puppet_server::webfs
  file { '/data/':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }

  file { '/data/r10k/':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    require => File['/data/'],
  }

  file { '/data/git/':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    require => File['/data/'],
  }

  file { '/data/git/puppet/':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    require => File['/data/git/'],
  }

  file { '/data/r10k/postrun.sh':
    owner  => root,
    group  => root,
    mode   => '0755',
    source => "puppet:///modules/${module_name}/data/r10k/postrun.sh"
  }

  file { '/data/r10k/r10k-cron.sh':
    owner  => root,
    group  => root,
    mode   => '0755',
    source => "puppet:///modules/${module_name}/data/r10k/r10k-cron.sh"
  }

  file { '/data/r10k/r10k-run.sh':
    owner  => root,
    group  => root,
    mode   => '0755',
    source => "puppet:///modules/${module_name}/data/r10k/r10k-run.sh"
  }

  file { '/data/r10k/r10k.yaml':
    owner  => root,
    group  => root,
    mode   => '0644',
    source => "puppet:///modules/${module_name}/data/r10k/r10k.yaml"
  }

  file { '/etc/cron.d/r10k':
    owner   => root,
    group   => root,
    mode    => '0644',
    content => "* * * * * root /data/r10k/r10k-cron.sh > /dev/null 2>&1\n"
  }

}
