#!/bin/bash

# shellcheck disable=SC1091
. _liferay_common.sh

function gen_github_config {
	block_begin "Generating GitHub config"

	local lockfile="/var/lib/teleport/.github_is_added.txt"

	if [ -f ${lockfile} ];
	then
		msg "GitHub SSO is already configured"

		return
	fi

	sed \
		-e "s@__GITHUB_ID__@${GITHUB_ID}@g" \
		-e "s@__GITHUB_REDIRECT_HOST__@${GITHUB_REDIRECT_HOST}@g" \
		-e "s@__GITHUB_SECRET__@${GITHUB_SECRET}@g" \
		/root/github.yaml.tpl > /root/github.yaml

	tctl create -f /root/github.yaml

	local return_code=${?}

	if [ ${return_code} -eq 0 ]
	then
		msg "GitHub SSO added successfully"

		touch ${lockfile}

		block_begin "Generating GitHub config"
	else
		fail "GitHub SSO added unsuccessfully"
		exit 1
	fi
}

function gen_teleport_config {
	block_begin "Generate Teleport config"

	CLUSTER_NAME=${CLUSTER_NAME/.*/}
	CLUSTER_NAME=${GITHUB_REDIRECT_HOST#*.}

	sed \
		-e "s@__CLUSTER_NAME__@${CLUSTER_NAME}@g" \
		-e "s@__GITHUB_REDIRECT_HOST__@${GITHUB_REDIRECT_HOST}@g" \
		/etc/teleport/teleport.yaml.tpl > /etc/teleport/teleport.yaml

	block_finish "Generate Teleport config"
}

function main {
	gen_teleport_config

	start_temporary

	gen_github_config

	stop_temporary

	start_teleport
}

function start_teleport {
	block_begin "Start production Teleport service"

	teleport start -c /etc/teleport/teleport.yaml
}

function start_temporary {
	block_begin "Start temporary Teleport service"

	teleport start -c /etc/teleport/teleport.yaml &
    PID="$!"

    for second in {120..0}
    do
        msg "Teleport init process in progress... ${second} seconds left"

		if (tctl status > /dev/null 2>&1)
        then
            break
        fi

        sleep 1
    done

	block_finish "Start temporary Teleport service"

    if [ "${second}" = 0 ]
    then
        fail "Teleport init process failed"

        exit 1
    fi
}

function stop_temporary {
	block_begin "Stop temporary Teleport service"

    if (! kill -s TERM "${PID}" || wait "${PID}")
    then
        fail "Temporary Teleport instance cannot be stopped"

        exit 1
    fi

	block_finish "Stop temporary Teleport service"
}

main