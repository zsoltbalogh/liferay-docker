#!/bin/bash

source ./_common.sh

function build_docker_image {
	local image_version=$(./release_notes.sh get-version)

	DOCKER_IMAGE_TAGS=()
	DOCKER_IMAGE_TAGS+=("liferay/servlet-container:${SERVLER_CONTAINER_IMAGE_VERSION}-${image_version}-${TIMESTAMP}")
	DOCKER_IMAGE_TAGS+=("liferay/servlet-container:${SERVLER_CONTAINER_IMAGE_VERSION}")

	docker build \
		--build-arg LABEL_BUILD_DATE=$(date "${CURRENT_DATE}" "+%Y-%m-%dT%H:%M:%SZ") \
		--build-arg LABEL_NAME="Servlet container for Liferay images - OS, JVM and Apache Tomcat" \
		--build-arg LABEL_VCS_REF=$(git rev-parse HEAD) \
		--build-arg LABEL_VCS_URL="https://github.com/liferay/liferay-docker" \
		--build-arg LABEL_VERSION="${image_version}" \
		$(get_docker_image_tags_args ${DOCKER_IMAGE_TAGS[@]}) \
		${TEMP_DIR} || exit 1
}

function check_usage {
	if [ ! -n "${LIFERAY_DOCKER_JAVA_VERSION}" ] || [ ! -n "${LIFERAY_DOCKER_TOMCAT_VERSION}" ]
	then
		echo "Usage: ${0} <push>"
		echo ""
		echo "The script reads the following environment variables:"
		echo ""
		echo "    LIFERAY_DOCKER_JAVA_VERSION (required): The major version of the JDK to include in the image"
		echo "    LIFERAY_DOCKER_TOMCAT_VERSION (required): The major.minor version of the Apache Tomcat."
		echo ""
		echo "Example: LIFERAY_DOCKER_JAVA_VERSION=8 LIFERAY_DOCKER_TOMCAT_VERSION=9.0 ${0} push"
		echo ""
		echo "Set \"push\" as a parameter to automatically push the image to Docker Hub."

		exit 1
	fi

	check_utils 7z curl docker java unzip
}

function configure {
	SERVLER_CONTAINER_IMAGE_VERSION=jdk${LIFERAY_DOCKER_JAVA_VERSION}-tomcat${LIFERAY_DOCKER_TOMCAT_VERSION}
}

function main {
	check_usage

	configure

	update_image servlet-container:${SERVLER_CONTAINER_IMAGE_VERSION}

	build_image os os || exit 1

	make_temp_directory templates/base

	build_docker_image

	push_docker_images ${1}

	clean_up_temp_directory
}

main ${@}