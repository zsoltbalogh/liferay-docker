#!/bin/bash

source ./_common.sh

function build_docker_image {
	local image_version=$(./release_notes.sh get-version)

	DOCKER_IMAGE_TAGS=()
	DOCKER_IMAGE_TAGS+=("liferay/servlet:${SERVLET_IMAGE_VERSION}-${image_version}-${TIMESTAMP}")
	DOCKER_IMAGE_TAGS+=("liferay/servlet:${SERVLET_IMAGE_VERSION}")

	docker build \
		--build-arg JAVA_PACKAGE=${DOCKER_IMAGE_JAVA_PACKAGE} \
		--build-arg JAVA_HOME=${DOCKER_IMAGE_JAVA_HOME} \
		--build-arg LABEL_BUILD_DATE=$(date "${CURRENT_DATE}" "+%Y-%m-%dT%H:%M:%SZ") \
		--build-arg LABEL_NAME="Servlet container for Liferay images - OS, JVM and Apache Tomcat" \
		--build-arg LABEL_VCS_REF=$(git rev-parse HEAD) \
		--build-arg LABEL_VCS_URL="https://github.com/liferay/liferay-docker" \
		--build-arg LABEL_VERSION="${image_version}" \
		$(get_docker_image_tags_args ${DOCKER_IMAGE_TAGS[@]}) \
		${TEMP_DIR} || exit 1
}

function configure {
	if [ ${LIFERAY_DOCKER_JAVA_VERSION} == "8" ]
	then
		DOCKER_IMAGE_JAVA_HOME=/usr/lib/jvm/zulu8
		DOCKER_IMAGE_JAVA_PACKAGE=zulu8-jdk
	else
		DOCKER_IMAGE_JAVA_HOME=/usr/lib/jvm/zulu11
		DOCKER_IMAGE_JAVA_PACKAGE=zulu11-jdk=11.0.5-r3
	fi
}

function main {
	set_servlet_image_version

	configure

	update_image servlet:${SERVLET_IMAGE_VERSION}

	build_image os os || exit 1

	make_temp_directory templates/servlet

	build_docker_image

	push_docker_images ${1}

	clean_up_temp_directory
}

main ${@}