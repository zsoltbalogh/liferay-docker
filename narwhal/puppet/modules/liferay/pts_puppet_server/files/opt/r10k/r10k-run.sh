#!/bin/bash

function lcd {
	cd "${1}" || exit 3
}

R10K_DIR="/opt/r10k"

lcd "${R10K_DIR}"

r10k -c r10k.yaml deploy environment

echo
echo "Deployed test environments:"
echo

# shellcheck disable=SC2010
ls --color=auto -1 /etc/puppetlabs/code/environments/ | grep -v "^production$"
