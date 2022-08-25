#!/bin/bash

function main {
	if [[ "${LIFERAY_ZABBIX_AGENT_ENABLED}" == "true" ]]
	then
		echo ""
		echo "[LIFERAY] Starting Zabbix Agent2."
		echo ""

		/usr/sbin/zabbix_agent2 -c /etc/zabbix/zabbix_agent2.conf &

		if [[ "${1}" == "wait" ]]
		then
			ZABBIX_PID=$!

			wait ${ZABBIX_PID}
		fi
	fi
}

main "${@}"