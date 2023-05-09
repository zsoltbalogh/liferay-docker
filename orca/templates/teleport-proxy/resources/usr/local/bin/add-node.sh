#!/bin/bash

TELEPORT_AUTH_SERVER="10.111.111.10:3025"

function gen_ca_pin {
	CA_PIN=$(tctl status | awk '/CA pin/{print $3}')

	return_code="${?}"

	if ! [ ${return_code} -eq 0 ]
	then
		echo "The command 'tctl status' returned with a non-zero exit code. Exiting."
		exit 1
	fi
}

function gen_invite_token {
	INVITE_TOKEN=$(tctl nodes add --ttl=5m --roles=node | grep "invite token:" | grep -Eo "[0-9a-z]{32}")

	return_code="${?}"

	if ! [ ${return_code} -eq 0 ]
	then
		echo "The command 'tctl nodes add --ttl=5m --roles=node' returned with a non-zero exit code. Exiting."
		exit 1
	fi
}

function list_tokens {
	echo "Available tokens:"

	tctl tokens ls
}

function main {
	gen_ca_pin

	gen_invite_token

	list_tokens

	print_join_command
}

function print_join_command {
	echo "Run the following command on the node to join:"
	echo "$ teleport start --roles=node --token=${INVITE_TOKEN} --ca-pin=${CA_PIN} --auth-server=${TELEPORT_AUTH_SERVER}"
}

main

