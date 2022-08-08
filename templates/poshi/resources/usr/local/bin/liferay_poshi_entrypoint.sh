#!/bin/bash

function main {
	cd /opt/liferay/poshi/${POSHI_ENVIRONMENT}

	gradle runPoshi
}

main "${@}"