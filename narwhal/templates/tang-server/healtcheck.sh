#!/bin/sh

set -e

curl --fail --location --show-error --silent http://127.0.0.1:9090/adv > /dev/null
