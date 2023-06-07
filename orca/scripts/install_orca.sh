#!/bin/bash

source $(dirname "$(readlink /proc/$$/fd/255 2>/dev/null)")/_liferay_common.sh

function main {
	apt-get update
	apt-get --yes install docker-compose git glusterfs-server pwgen

	if (! command -v yq &> /dev/null)
	then
		snap install yq
	fi

	mkdir -p /opt/liferay/orca

	lc_cd /opt/liferay/orca

	git init
	git remote add origin https://github.com/liferay/liferay-docker.git
	git config core.sparseCheckout true

	echo "orca" >> .git/info/sparse-checkout

	git pull origin master

	#
	# TODO Fix /opt/liferay/orca/orca
	#

	lc_cd orca

	#
	# TODO install
	#

	scripts/orca.sh install
}

main