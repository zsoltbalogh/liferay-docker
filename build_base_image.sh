#!/bin/bash

source ./_common.sh

function build_docker_image {
	local image_version=$(./release_notes.sh get-version)

	DOCKER_IMAGE_TAGS=()
	DOCKER_IMAGE_TAGS+=("liferay/base:${SERVLET_CONTAINER_IMAGE_VERSION}-${image_version}-${TIMESTAMP}")
	DOCKER_IMAGE_TAGS+=("liferay/base:${SERVLET_CONTAINER_IMAGE_VERSION}")

	docker build \
		--build-arg LABEL_BUILD_DATE=$(date "${CURRENT_DATE}" "+%Y-%m-%dT%H:%M:%SZ") \
		--build-arg LABEL_NAME="Running environment for Liferay images - OS, JVM and tools" \
		--build-arg LABEL_VCS_REF=$(git rev-parse HEAD) \
		--build-arg LABEL_VCS_URL="https://github.com/liferay/liferay-docker" \
		--build-arg LABEL_VERSION="${image_version}" \
		--build-arg PARENT_IMAGE="liferay/servlet-container:${SERVLET_CONTAINER_IMAGE_VERSION}" \
		$(get_docker_image_tags_args ${DOCKER_IMAGE_TAGS[@]}) \
		${TEMP_DIR} || exit 1
}

function main {
	set_servlet_container_image_version

	update_image base:${SERVLET_CONTAINER_IMAGE_VERSION}

	build_image servlet_container ${SERVLET_CONTAINER_IMAGE_VERSION}

	make_temp_directory templates/base

	build_docker_image

	push_docker_images ${1}

	clean_up_temp_directory
}

main ${@}