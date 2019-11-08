#!/bin/bash

source ./_common.sh

function build_docker_image {
	DOCKER_IMAGE_TAGS=()

	if [[ ${RELEASE_FILE_URL%} == */snapshot-* ]]
	then
		DOCKER_IMAGE_TAGS+=("liferay/${DOCKER_IMAGE_NAME}:${RELEASE_BRANCH}-${RELEASE_VERSION}-${RELEASE_HASH}")
		DOCKER_IMAGE_TAGS+=("liferay/${DOCKER_IMAGE_NAME}:${RELEASE_BRANCH}-$(date "${CURRENT_DATE}" "+%Y%m%d")")
		DOCKER_IMAGE_TAGS+=("liferay/${DOCKER_IMAGE_NAME}:${RELEASE_BRANCH}")
	else
		DOCKER_IMAGE_TAGS+=("liferay/${DOCKER_IMAGE_NAME}:${RELEASE_VERSION}-${TIMESTAMP}")
		DOCKER_IMAGE_TAGS+=("liferay/${DOCKER_IMAGE_NAME}:${RELEASE_VERSION}")
	fi

	local docker_image_tags_args=""

	for docker_image_tag in "${DOCKER_IMAGE_TAGS[@]}"
	do
		docker_image_tags_args="${docker_image_tags_args} --tag ${docker_image_tag}"
	done

	docker build \
		--build-arg LABEL_BUILD_DATE=$(date "${CURRENT_DATE}" "+%Y-%m-%dT%H:%M:%SZ") \
		--build-arg LABEL_NAME="${LABEL_NAME}" \
		--build-arg LABEL_VCS_REF=$(git rev-parse HEAD) \
		--build-arg LABEL_VCS_URL="https://github.com/liferay/liferay-docker" \
		--build-arg LABEL_VERSION="${LABEL_VERSION}" \
		$(echo ${docker_image_tags_args}) \
		${TEMP_DIR}
}

function check_usage {
	if [ ! -n "${1}" ]
	then
		echo "Usage: ${0} release-url <push>"
		echo ""
		echo "Example: ${0} files.liferay.com/private/ee/portal/7.2.10/liferay-dxp-tomcat-7.2.10-ga1-20190531140450482.7z"
		echo ""
		echo "Set \"push\" as the second parameter to automatically push the image to Docker Hub."

		exit 1
	fi

	check_utils 7z curl docker java unzip
}

function download_trial_dxp_license {
	if [[ ${RELEASE_FILE_NAME} == *-commerce-enterprise-* ]] || [[ ${RELEASE_FILE_NAME} == *-dxp-* ]]
	then
		if [ -z "${LIFERAY_DOCKER_LICENSE_CMD}" ]
		then
			echo "Please set the environment variable LIFERAY_DOCKER_LICENSE_CMD to generate a trial DXP license."

			exit 1
		else
			mkdir -p ${TEMP_DIR}/liferay/deploy

			license_file_name=license-$(date "${CURRENT_DATE}" "+%Y%m%d").xml

			eval "curl --silent --header \"${LIFERAY_DOCKER_LICENSE_CMD}?licenseLifetime=$(expr 1000 \* 60 \* 60 \* 24 \* 30)&startDate=$(date "${CURRENT_DATE}" "+%Y-%m-%d")&owner=hello%40liferay.com\" > ${TEMP_DIR}/liferay/deploy/${license_file_name}"

			sed -i "s/\\\n//g" ${TEMP_DIR}/liferay/deploy/${license_file_name}
			sed -i "s/\\\t//g" ${TEMP_DIR}/liferay/deploy/${license_file_name}
			sed -i "s/\"<?xml/<?xml/" ${TEMP_DIR}/liferay/deploy/${license_file_name}
			sed -i "s/license>\"/license>/" ${TEMP_DIR}/liferay/deploy/${license_file_name}
			sed -i 's/\\"/\"/g' ${TEMP_DIR}/liferay/deploy/${license_file_name}
			sed -i 's/\\\//\//g' ${TEMP_DIR}/liferay/deploy/${license_file_name}

			if [ ! -e ${TEMP_DIR}/liferay/deploy/${license_file_name} ]
			then
				echo "Trial DXP license does not exist at ${TEMP_DIR}/liferay/deploy/${license_file_name}."

				exit 1
			else
				echo "Trial DXP license exists at ${TEMP_DIR}/liferay/deploy/${license_file_name}."

				#exit 1
			fi
		fi
	fi

	if [[ ${RELEASE_FILE_NAME} == *-commerce-enterprise-* ]]
	then
		mkdir -p ${TEMP_DIR}/liferay/data/license

		cp LiferayCommerce_enterprise.li ${TEMP_DIR}/liferay/data/license
	fi
}

function main {
	check_usage ${@}

	set_container_variables

	make_temp_directory

	prepare_temp_directory ${@}

	prepare_tomcat

	download_trial_dxp_license

	build_docker_image

	push_docker_images ${@}

	clean_up_temp_directory
}

function prepare_temp_directory {
	RELEASE_FILE_NAME=${1##*/}

	RELEASE_FILE_URL=${1}

	if [[ ${RELEASE_FILE_URL} != http://mirrors.*.liferay.com* ]] && [[ ${RELEASE_FILE_URL} != http://release* ]]
	then
		RELEASE_FILE_URL=http://mirrors.lax.liferay.com/${RELEASE_FILE_URL}
	fi

	local release_dir=${1%/*}

	release_dir=${release_dir#*com/}
	release_dir=${release_dir#*com/}
	release_dir=${release_dir#*liferay-release-tool/}
	release_dir=${release_dir#*private/ee/}
	release_dir=releases/${release_dir}

	if [ ! -e ${release_dir}/${RELEASE_FILE_NAME} ]
	then
		echo ""
		echo "Downloading ${RELEASE_FILE_URL}."
		echo ""

		mkdir -p ${release_dir}

		curl -f -o ${release_dir}/${RELEASE_FILE_NAME} ${RELEASE_FILE_URL} || exit 2
	fi

	if [[ ${RELEASE_FILE_NAME} == *.7z ]]
	then
		7z x -O${TEMP_DIR} ${release_dir}/${RELEASE_FILE_NAME} || exit 3
	else
		unzip -q ${release_dir}/${RELEASE_FILE_NAME} -d ${TEMP_DIR}  || exit 3
	fi

	mv ${TEMP_DIR}/liferay-* ${TEMP_DIR}/liferay
}

function push_docker_images {
	if [ "${2}" == "push" ]
	then
		for docker_image_tag in "${DOCKER_IMAGE_TAGS[@]}"
		do
			docker push ${docker_image_tag}
		done
	fi
}

function set_container_variables {
	if [[ ${RELEASE_FILE_NAME} == *-commerce-enterprise-* ]]
	then
		DOCKER_IMAGE_NAME="commerce-enterprise"
		LABEL_NAME="Liferay Commerce Enterprise"
	elif [[ ${RELEASE_FILE_NAME} == *-commerce-* ]]
	then
		DOCKER_IMAGE_NAME="commerce"
		LABEL_NAME="Liferay Commerce"
	elif [[ ${RELEASE_FILE_NAME} == *-dxp-* ]] || [[ ${RELEASE_FILE_NAME} == *-private* ]]
	then
		DOCKER_IMAGE_NAME="dxp"
		LABEL_NAME="Liferay DXP"
	elif [[ ${RELEASE_FILE_NAME} == *-portal-* ]]
	then
		DOCKER_IMAGE_NAME="portal"
		LABEL_NAME="Liferay Portal"
	else
		echo "${RELEASE_FILE_NAME} is an unsupported release file name."

		exit 1
	fi

	if [[ ${RELEASE_FILE_URL%} == */snapshot-* ]]
	then
		DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME}-snapshot
	fi

	if [[ ${RELEASE_FILE_URL} == http://release* ]]
	then
		DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME}-snapshot
	fi

	RELEASE_VERSION=${RELEASE_FILE_URL%/*}

	RELEASE_VERSION=${RELEASE_VERSION##*/}

	if [[ ${RELEASE_FILE_URL} == http://release* ]]
	then
		RELEASE_VERSION=${RELEASE_FILE_URL#*tomcat-}
		RELEASE_VERSION=${RELEASE_VERSION%.*}
	fi

	LABEL_VERSION=${RELEASE_VERSION}

	if [[ ${RELEASE_FILE_URL%} == */snapshot-* ]]
	then
		RELEASE_BRANCH=${RELEASE_FILE_URL%/*}

		RELEASE_BRANCH=${RELEASE_BRANCH%/*}
		RELEASE_BRANCH=${RELEASE_BRANCH%-private*}
		RELEASE_BRANCH=${RELEASE_BRANCH##*-}

		RELEASE_HASH=$(cat ${TEMP_DIR}/liferay/.githash)

		RELEASE_HASH=${RELEASE_HASH:0:7}

		if [[ ${RELEASE_BRANCH} == master ]]
		then
			LABEL_VERSION="Master Snapshot on ${LABEL_VERSION} at ${RELEASE_HASH}"
		else
			LABEL_VERSION="${RELEASE_BRANCH} Snapshot on ${LABEL_VERSION} at ${RELEASE_HASH}"
		fi
	fi
}

main ${@}