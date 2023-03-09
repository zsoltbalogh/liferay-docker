class pts_sysctl {

  sysctl { 'net.ipv4.ip_nonlocal_bind':
    value => 1
  }

  if $facts['virtual'] != lxc {
    sysctl { 'fs.suid_dumpable':
      value => '1',
    }
  }

  sysctl { 'net.ipv4.tcp_retries2':
    value => '7',
  }

  if $facts['virtual'] != lxc {
    sysctl { 'kernel.randomize_va_space':
      value => '1',
    }
  }

  sysctl { 'net.ipv4.conf.all.log_martians':
    value => '0',
  }

  sysctl { 'net.ipv4.conf.all.rp_filter':
    value => '1',
  }

  sysctl { 'net.ipv4.conf.default.rp_filter':
    value => '1',
  }

  sysctl { 'net.ipv4.conf.all.accept_redirects':
    value => '0',
  }

  sysctl { 'net.ipv4.conf.all.secure_redirects':
    value => '0',
  }

  sysctl { 'net.ipv4.conf.all.send_redirects':
    value => '0',
  }

  sysctl { 'net.ipv4.conf.default.accept_redirects':
    value => '0',
  }

  sysctl { 'net.ipv4.conf.default.secure_redirects':
    value => '0',
  }

  sysctl { 'net.ipv4.conf.default.send_redirects':
    value => '0',
  }

  if $facts['virtual'] != 'lxc' {
    sysctl { 'net.core.default_qdisc':
      value => 'fq_codel',
    }
  }

  if $facts['virtual'] != lxc {
    sysctl { 'net.ipv4.tcp_congestion_control':
      value => 'bbr',
    }
  }
}
