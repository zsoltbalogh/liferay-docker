#!/bin/bash

function lcd {
	cd "${1}" || exit 3
}


TIMESTAMP_FILE="/opt/r10k/timestamp.txt"
PUPPET_DIR="/etc/puppetlabs/code/environments"
BASE_DIR="/opt/r10k"
CODE_DIR="${BASE_DIR}/code"
TMP_DIR="${BASE_DIR}/tmp"

rm -fr "${BASE_DIR}/tmp/"

mkdir "${BASE_DIR}/tmp/"

for branch in $(ls "${CODE_DIR}");
do
        ln -s "${CODE_DIR}/${branch}/narwhal/puppet" "${TMP_DIR}/${branch}"
done

lcd ${TMP_DIR}
mv liferay_master production
rm -rf "${PUPPET_DIR}"
mv "${TMP_DIR}" "${PUPPET_DIR}"
date "+%s" > "${TIMESTAMP_FILE}"
