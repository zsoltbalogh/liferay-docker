#!/bin/bash

function build_dxp {
	trap 'return ${LIFERAY_COMMON_EXIT_CODE_BAD}' ERR

	if [ -e "${BUILD_DIR}"/built-sha ] && [ $(cat "${BUILD_DIR}"/built-sha) == "${NARWHAL_GIT_SHA}${NARWHAL_HOTFIX_TESTING_SHA}" ]
	then
		echo "${NARWHAL_GIT_SHA} is already built in the ${BUILD_DIR}, skipping the compile_dxp step."

		return "${LIFERAY_COMMON_EXIT_CODE_SKIPPED}"
	fi

	rm -fr "${BUNDLES_DIR}"

	lc_cd /opt/liferay/dev/projects/liferay-portal-ee/tools/release

	ant -f

	rm -f apache-tomcat*

	echo "${NARWHAL_GIT_SHA}${NARWHAL_HOTFIX_TESTING_SHA}" > "${BUILD_DIR}"/built-sha
}

function decrement_module_versions {
	lc_cd /opt/liferay/dev/projects/liferay-portal-ee/modules

	find apps dxp/apps -name bnd.bnd -type f -print0 | while IFS= read -r -d '' bnd
	do
		local module_path=$(dirname "${bnd}")

		if [ ! -e ".releng/${module_path}/artifact.properties" ]
		then
			continue
		fi

		local bundle_version=$(lc_get_property "${bnd}" "Bundle-Version")

		local major_minor_version=${bundle_version%.*}
		local micro_version=${bundle_version##*.}

		micro_version=$((micro_version - 1))

		sed -i -e "s/Bundle-Version: ${bundle_version}/Bundle-Version: ${major_minor_version}.${micro_version}/" "${bnd}"
	done
}

function get_dxp_version {
	lc_cd /opt/liferay/dev/projects/liferay-portal-ee

	local major=$(lc_get_property release.properties "release.info.version.major")
	local minor=$(lc_get_property release.properties "release.info.version.minor")

	local branch="${major}.${minor}.x"

	if [ "${branch}" == "7.4.x" ]
	then
		branch=master
	fi

	local bug_fix=$(lc_get_property release.properties "release.info.version.bug.fix[${branch}-private]")
	local trivial=$(lc_get_property release.properties "release.info.version.trivial")

	echo "${major}.${minor}.${bug_fix}-u${trivial}"
}

function pre_compile_setup {
	lc_cd /opt/liferay/dev/projects/liferay-portal-ee

	if [ -e "${BUILD_DIR}"/built-sha ] && [ $(cat "${BUILD_DIR}"/built-sha) == "${NARWHAL_GIT_SHA}${NARWHAL_HOTFIX_TESTING_SHA}" ]
	then
		echo "${NARWHAL_GIT_SHA} is already built in the ${BUILD_DIR}, skipping the pre_compile_setup step."

		return "${LIFERAY_COMMON_EXIT_CODE_SKIPPED}"
	fi

	rm -fr /root/.liferay
	mkdir -p /opt/liferay/build_cache
	ln -s /opt/liferay/build_cache /root/.liferay

	ant setup-profile-dxp
}