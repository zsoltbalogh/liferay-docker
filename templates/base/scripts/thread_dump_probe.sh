#!/bin/bash

function check_usage {
	FILE_PATH="/"
	PORT=8080
	TIMEOUT=20

	while [ "${1}" != "" ]
	do
		case $1 in
			-d)
				shift
				DOMAIN=${1}
				;;
			-f)
				shift
				FILE_PATH=${1}
				;;
			-p)
				shift
				PORT=":${1}"
				;;
			-t)
				shift
				TIMEOUT=${1}
				;;
			-c)
				shift
				CONTENT=${1}
				;;
			-h)
				print_help
				;;
			*)
				print_help
				;;
		esac
		shift
	done

	if [ ! -n "${DOMAIN}" ]
	then
		echo "Please set the domain variable."

		exit 1
	fi
}

function main {
	check_usage "${@}"

	local curl_command="curl --url ${DOMAIN}${PORT} -m ${TIMEOUT} ${DOMAIN}${PORT}${FILE_PATH}"

	if [ -n "${CONTENT}" ]
	then
		curl_command="${curl_command} | grep ${CONTENT} > /dev/null"
	fi

	eval "${curl_command}"
	local ret=$?

	if [ ${ret} -gt 1 ]
	then
		kill -3 $(ps -ef | grep org.apache.catalina.startup.Bootstrap | grep -v grep | awk '{ print $1 }')
	fi

	exit ${ret}
}

function print_help {
	echo "Usage: ${0} -d <domain> -f <path> -c <content> -t <timeout> -p <port>"
	echo ""
	echo "The script can be configured by using these parameters:"
	echo ""
	echo "	-d (required): the domain the site is responding to with valid content."
	echo "	-f (optional, default: /): the path to check on the domain."
	echo "	-c (optional, default: skipping to check): checks if the site response contains this string."
	echo "	-t (optional, default: 20): timeout in seconds."
	echo "	-p (optional, default: 8080): the http port to check."
	echo ""
	echo "Example: ${0} -d \"http://localhost\" -t 20 -p 8080 -f \"/c/portal/layout\""

	exit 2
}

main "${@}"