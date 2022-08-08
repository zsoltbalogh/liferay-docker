#!/bin/bash

function configure_poshi {
	echo "browser.chrome.bin.file=/usr/local/chrome-linux/chrome" >> /opt/liferay/poshi/${POSHI_ENVIRONMENT}/poshi-ext.properties
}

function main {
	configure_poshi

	run_poshi
}

function run_poshi {
	cd /opt/liferay/poshi/${POSHI_ENVIRONMENT}

	gradle runPoshi
}

main "${@}"