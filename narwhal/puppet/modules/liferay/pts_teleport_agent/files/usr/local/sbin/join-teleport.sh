#!/bin/bash

if [ ! -f /etc/default/teleport ]
then
	echo "File '/etc/default/teleport' is missing. Exiting."
	exit 1
else
	. /etc/default/teleport
fi

INVITE_TOKEN="${1}"
CA_PIN="${2}"

systemctl stop teleport

rm -rf /var/lib/teleport

teleport start --roles=node --token="${INVITE_TOKEN}" --ca-pin="${CA_PIN}" --auth-server="${AUTH_SERVER}"
