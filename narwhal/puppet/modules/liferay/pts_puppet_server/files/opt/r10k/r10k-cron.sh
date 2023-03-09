#!/bin/bash

git -C /opt/r10k/liferay-docker remote -v update 2>&1 | grep -- " -> origin/" | grep -v "= \[up to date\]" | grep -q "[a-z]"
RET="$?"

if [ "$RET" = 0 ];
then
	/opt/r10k/r10k-run.sh
fi
