class pts_packages {

	class {
		'apt':
			update => {
				frequency => 'daily',
			},
	}

	$minute = fqdn_rand(59)

	file {
		'/etc/cron.d/backup-deb-packages-export':
			content => "${minute} 22 * * * root /usr/bin/dpkg -l | grep '^ii' | awk \'{ print \$2 }\' | sort > /etc/deb_packages.list 2>&1\n",
			group => 'root',
			mode => '0644',
			owner => 'root',
	}

	include pts_packages::absent
	include pts_packages::latest

}
