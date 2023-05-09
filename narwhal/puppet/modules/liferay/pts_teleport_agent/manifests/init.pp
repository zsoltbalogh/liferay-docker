class pts_teleport_agent {

	file {
		'/etc/apt/sources.list.d/teleport.list':
			content => "deb [signed-by=/etc/apt/teleport.asc] https://apt.releases.teleport.dev/ubuntu ${facts['os']['distro']['codename']} stable/v12\n",
			group => root,
			mode => '0664',
			notify => Exec['apt_update'],
			owner => root,
			require => File['/etc/apt/teleport.asc'],
	}

	file {
		'/etc/apt/teleport.asc':
			group => root,
			mode => '0664',
			owner => root,
			source => "puppet:///modules/${module_name}/etc/apt/teleport.asc",
	}

	file {
		'/etc/default/teleport':
			content => "AUTH_SERVER=${pts_location::teleport_auth_server}\n",
			group => root,
			mode => '0664',
			owner => root,
	}

	file {
		'/etc/systemd/system/teleport.service':
			content => epp("${module_name}/etc/systemd/system/teleport.service.epp"),
			group => root,
			mode => '0664',
			notify => Service['teleport'],
			owner => root,
			require => Package['teleport'],
	}

	package {
		'teleport':
			ensure => latest,
			require => File['/etc/apt/sources.list.d/teleport.list'],
	}

	service {
		'teleport':
			ensure => running,
			require => Package['teleport'],
	}
}
