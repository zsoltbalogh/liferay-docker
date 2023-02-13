#!/bin/bash

tctl create -f /root/host-certifier.yaml
tctl create -f /root/github.yaml


ADDR=teleport-agent-test.latest_default

dir_export="/etc/ssh/export"

tctl auth sign \
      --host=${ADDR?} \
      --format=openssh \
      --out=${dir_export}/${ADDR}

tctl auth export --type=user | sed "s/cert-authority\ //" > ${dir_export}/teleport_user_ca.pub

chmod 600 ${dir_export}/*
