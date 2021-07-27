#!/bin/bash

function check_usage {
	FILE_PATH="/"
    TIMEOUT=20

    while [ "${1}" != "" ]
    do
        case $1 in
            -d | --domain )
                shift
                DOMAIN=${1}
                ;;
            -f | --fpath )
                shift
                FILE_PATH=${1}
                ;;
            -p | --port )
                shift
                PORT=":${1}"
                ;;
            -t | --timeout )
                shift
                TIMEOUT=${1}
                ;;
            -c | --content )
                shift
                CONTENT=${1}
                ;;
            -h | --help )
                print_help
                ;;
            * )
                print_help
                ;;
        esac
        shift
    done

    if [ -z ${DOMAIN+x} ]
    then
        echo "Please set the domain variable."
    fi
}

function main {
	check_usage "${@}"

    local curl_command="curl --url ${DOMAIN}${PORT} -m ${TIMEOUT} ${DOMAIN}${PORT}${FILE_PATH}"

    if [[ -n ${CONTENT+x} ]]
    then
        curl_command="${curl_command} | grep ${CONTENT}"
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
  echo "Use -d or --domain to set the host domain (url), which the script checks. Example: -d https://en.wikipedia.org"
  echo "Use -f or --fpath set the rest of the url or the path after the host. Example: -p /wiki/Main_Page"
  echo "Use -c or --content to set a filter. With this set, the check will only be considered successful, if the keyword is present. Example: -c BakerStreet"
  echo "Use -t or --timeout to set a timeout in seconds for the check, default is 20 seconds. Example: -t 10"
  echo "Use -p or --port to set the port on which the domain is reachable. Example: -p 8080"

  exit 2
}

main "${@}"