#!/bin/bash

function check_usage {
	NUMBER_OF_THREAD_DUMPS=20
	THREAD_DUMPS_DIR="${LIFERAY_HOME}/data/sre/thread_dumps"

	while [ "${1}" != "" ]
	do
		case ${1} in
			-d)
				shift

				THREAD_DUMPS_DIR=${1}

				;;
			-h)
				print_help

				;;
			-n)
				shift

				NUMBER_OF_THREAD_DUMPS=${1}

				;;
			-s)
				shift

				LIFERAY_DOCKER_THREAD_DUMP_INTERVAL=${1}

				;;
			*)
				print_help

				;;
		esac

		shift
	done
}

function generate_thread_dump {
	local date=$(date +'%Y-%m-%d')

	mkdir -p "${THREAD_DUMPS_DIR}/${date}"

	local id=${1}
	local time=$(date +'%H-%M-%S')

	echo "[Liferay] Generating ${THREAD_DUMPS_DIR}/${date}/thread_dump-${HOSTNAME}-${time}-${id}.txt.gz"

	local thread_dump=$(jattach $(cat "${LIFERAY_PID}") threaddump)

	THREAD_DUMP="${THREAD_DUMPS_DIR}/${date}/thread_dump-${HOSTNAME}-${time}-${id}.txt"

	echo -e "${thread_dump}" > "${THREAD_DUMP}"

	gzip "${THREAD_DUMP}"
}

function main {
	check_usage "${@}"

	if [[ "${LIFERAY_CONTAINER_STATUS_ENABLED}" != "true" ]]
	then
		echo "Set the environment variable \"LIFERAY_CONTAINER_STATUS_ENABLED\" to \"true\" to run ${0}."
		
		exit 2
	else
		while grep -q "live" /opt/liferay/container_status && [ "$LIFERAY_DOCKER_THREAD_DUMP_INTERVAL" -eq 0 ]
		do
			generate_thread_dump 1
			sleep 5
		done

		while grep -q "live" /opt/liferay/container_status && [ "$LIFERAY_DOCKER_THREAD_DUMP_INTERVAL" -ne 0 ]
		do
			for i in $(seq 1 "${NUMBER_OF_THREAD_DUMPS}")
			do
				generate_thread_dump "${i}"
				sleep "${LIFERAY_DOCKER_THREAD_DUMP_INTERVAL}"
			done
			LIFERAY_DOCKER_THREAD_DUMP_INTERVAL=0
		done
	
		while ! grep -q "live" /opt/liferay/container_status && [ "$LIFERAY_DOCKER_THREAD_DUMP_INTERVAL" -ne 0 ]
		do
			generate_thread_dump 1
			sleep 5
		done
	fi

	echo "[Liferay] Generated thread dumps"
}

function print_help {
	echo "Usage: ${0}"
	echo ""
	echo "The script can be configured with the following arguments:"
	echo ""
	echo "	-d (optional): Directory path to which the thread dumps are saved"
	echo "	-n (optional): Number of thread dumps to generate"
	echo "	-s (optional): Sleep in seconds between two thread dumps"
	echo ""
	echo "Example: ${0} -d \"${THREAD_DUMPS_DIR}\" -n ${NUMBER_OF_THREAD_DUMPS} -s ${LIFERAY_DOCKER_THREAD_DUMP_INTERVAL}"

	exit 2
}

main "${@}"