#!/bin/bash

function add_lock {
	hostname > "${LIFERAY_CONTAINER_STARTUP_LOCK_FILE}"

	sleep 2

	if [ "$(hostname)" != "$(cat "${LIFERAY_CONTAINER_STARTUP_LOCK_FILE}")" ]
	then
		echo "Unable to acquire lock."

		wait_until_free

		add_lock
	fi
}

function wait_until_free {
	while [ -e "${LIFERAY_CONTAINER_STARTUP_LOCK_FILE}" ] && [ "$(hostname)" != "$(cat "${LIFERAY_CONTAINER_STARTUP_LOCK_FILE}")" ]
	do
		echo "Wait for $(cat "${LIFERAY_CONTAINER_STARTUP_LOCK_FILE}") to start up."

		sleep 3
	done

	echo "Acquiring lock."
}

function main {
	wait_until_free

	add_lock
}

main