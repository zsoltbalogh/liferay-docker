#!/bin/bash

function docker_compose {
	if (command -v docker-compose &>/dev/null)
	then
		docker-compose "${@}"
	else
		docker compose "${@}"
	fi
}