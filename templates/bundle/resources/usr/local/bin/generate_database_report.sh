#!/bin/bash

source /usr/local/bin/_liferay_common.sh

function check_usage {
	lc_check_utils mysql || exit 1

	mkdir -p "${LIFERAY_REPORTS_DIRECTORY}"

	QUERY_FILE=$(mktemp)

	TOC_FILE=$(mktemp)
}

function main {
	check_usage

	echo "<h1>Table of contents</h1>" >> "${TOC_FILE}"

	lc_time_run run_query INFORMATION_SCHEMA "SELECT * FROM INNODB_LOCK_WAITS;"

	lc_time_run run_query INFORMATION_SCHEMA "SELECT * FROM INNODB_LOCKS WHERE LOCK_TRX_ID IN (SELECT BLOCKING_TRX_ID FROM INNODB_LOCK_WAITS);"

	for LCP_SECRET_DATABASE_NAME in $(mysql --connect-timeout=10 -D "${LCP_SECRET_DATABASE_NAME}" -e "SHOW DATABASES;" -h "database--route" -N -p"${LCP_SECRET_DATABASE_PASSWORD}" -s -u "${LCP_SECRET_DATABASE_USER}" | grep -E "lportal|lpartition")
	do
		lc_time_run run_query "${LCP_SECRET_DATABASE_NAME}" "SHOW ENGINE INNODB STATUS;"

		lc_time_run run_query "${LCP_SECRET_DATABASE_NAME}" "SELECT * FROM VirtualHost;"

		lc_time_run run_query "${LCP_SECRET_DATABASE_NAME}" "SELECT TABLE_NAME, TABLE_ROWS from information_schema.TABLES;"

		lc_time_run run_query "${LCP_SECRET_DATABASE_NAME}" "SELECT * FROM DDMTemplate;"

		lc_time_run run_query "${LCP_SECRET_DATABASE_NAME}" "SELECT * FROM FragmentEntryLink;"

		lc_time_run run_query "${LCP_SECRET_DATABASE_NAME}" "SELECT * FROM QUARTZ_TRIGGERS;"
	done

	sed -e "s#<TD>#<TD><PRE>#g" -i "${QUERY_FILE}"
	sed -e "s#</TD>#</PRE></TD>#g" -i "${QUERY_FILE}"

	REPORTS_FILE="${LIFERAY_REPORTS_DIRECTORY}"/database_query_report_$(date +'%Y-%m-%d_%H-%M-%S').html

	cat "${TOC_FILE}" "${QUERY_FILE}" > "${REPORTS_FILE}"

	rm "${TOC_FILE}" "${QUERY_FILE}"
}

function run_query {
	ANCHOR_ID=$((ANCHOR_ID+1))

	echo "<a href=\"#${ANCHOR_ID}\">${ANCHOR_ID}. ${1}: ${2}</a><br />" >> "${TOC_FILE}"

	echo "<h1 id=\"${ANCHOR_ID}\">${1}: ${2}</h1>" >> "${QUERY_FILE}"

	mysql --connect-timeout=10 -D "${1}" -e "${2}" -H -p"${LCP_SECRET_DATABASE_PASSWORD}" -u "${LCP_SECRET_DATABASE_USER}" >> "${QUERY_FILE}"
}

main "${@}"