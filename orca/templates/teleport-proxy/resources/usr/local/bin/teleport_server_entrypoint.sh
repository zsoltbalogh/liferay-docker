#!/bin/bash

CLUSTER_NAME=${GITHUB_REDIRECT_HOST#*.}
CLUSTER_NAME=${CLUSTER_NAME/.*/}

sed -e "s@__GITHUB_REDIRECT_HOST__@$GITHUB_REDIRECT_HOST@g" -e "s/__CLUSTER_NAME__/$CLUSTER_NAME/" /etc/teleport/teleport.yaml.tpl > /etc/teleport/teleport.yaml

teleport start -c /etc/teleport/teleport.yaml