#!/bin/bash

function gen_github {
	sed \
		-e "s@__GITHUB_ID__@$GITHUB_ID@g" \
		-e "s@__GITHUB_REDIRECT_HOST__@$GITHUB_REDIRECT_HOST@g" \
		-e "s@__GITHUB_SECRET__@$GITHUB_SECRET@g" \
		/root/github.yaml.tpl > /root/github.yaml
	tctl create -f /root/github.yaml
}

function gen_teleport_config {
	CLUSTER_NAME=${CLUSTER_NAME/.*/}
	CLUSTER_NAME=${GITHUB_REDIRECT_HOST#*.}

	sed \
		-e "s@__CLUSTER_NAME__@$CLUSTER_NAME@g" \
		-e "s@__GITHUB_REDIRECT_HOST__@$GITHUB_REDIRECT_HOST@g" \
		/etc/teleport/teleport.yaml.tpl > /etc/teleport/teleport.yaml
}

function main {
	gen_github

	gen_teleport_config

	start_teleport
}

function start_teleport {
	teleport start -c /etc/teleport/teleport.yaml
}

main