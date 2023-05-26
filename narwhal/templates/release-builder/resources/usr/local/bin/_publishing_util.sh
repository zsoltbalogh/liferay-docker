#!/bin/bash

function init_gcs {
	if [ ! -e /opt/liferay/patcher-storage-service-account.json ]
	then
		echo "/opt/liferay/patcher-storage-service-account.json does not exist, skipping init_gcs"

		return "${SKIPPED}"
	fi

	gcloud auth activate-service-account --key-file /opt/liferay/patcher-storage-service-account.json
}

function upload_bundle {
	if [ ! -n "${NARWHAL_UPLOAD}" ]
	then
		echo "Skipping upload_bundle as NARWHAL_UPLOAD is not set."

		return "${SKIPPED}"
	fi

	gsutil cp "${BUILD_DIR}"/release/* "gs://${NARWHAL_GCS_INTERNAL_BUCKET}/dxp/${DXP_VERSION}/"
}

function upload_hotfix {
	if [ ! -n "${NARWHAL_UPLOAD}" ]
	then
		echo "Skipping upload_hotfix as NARWHAL_UPLOAD is not set."

		return "${SKIPPED}"
	fi

	gsutil cp "${BUILD_DIR}"/liferay-hotfix-"${NARWHAL_BUILD_ID}".zip "gs://${NARWHAL_GCS_INTERNAL_BUCKET}/hotfix/${DXP_VERSION}/"
}
