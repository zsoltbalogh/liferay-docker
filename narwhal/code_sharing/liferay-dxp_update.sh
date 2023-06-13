#!/bin/bash

# shellcheck disable=2002,2013

set -e
set -o pipefail

source $(dirname "$(readlink /proc/$$/fd/255 2>/dev/null)")/_liferay_common.sh

BASE_DIR="${PWD}"

GITHUB_ADDRESS="git@github.com:${GITHUB_PROJECT}"
GITHUB_PROJECT="${GITHUB_PROJECT:-liferay}"

REPO_NAME_DXP="${REPO_NAME_DXP:-liferay-dxp}"
REPO_NAME_EE="liferay-portal-ee"

REPO_PATH_DXP="${BASE_DIR}/${REPO_NAME_DXP}"
REPO_PATH_EE="${BASE_DIR}/${REPO_NAME_EE}"

TAGS_FILE_DXP="/tmp/tags_file_dxp.txt"
TAGS_FILE_EE="/tmp/tags_file_ee.txt"
TAGS_FILE_NEW="/tmp/tags_file_new.txt"

VERSION="${1}"

function check_param {
	if [ -z "${1}" ]
	then
		echo "${2}"
		exit 1
	fi
}

function git_add {
	echo -n ">>>> Running 'git add'..."
	git add .
	echo "done."
}

function git_checkout_branch {
	local branch_name="${1}"

	check_param "${branch_name}" "Missing branch name"

	lc_cd "${REPO_PATH_DXP}"

	if (git show-ref --quiet "${branch_name}")
	then
		echo -n "Checking out branch '${branch_name}'..."
		git checkout -f -q "${branch_name}"
		echo "done."
	else
		echo -n "'No ${branch_name}' branch exists, creating..."
		git branch "${branch_name}"
		git checkout -f -q "${branch_name}"
		echo "done."
	fi
}

function git_checkout_tag {
	local tag_name="${1}"

	echo -n ">>>> Checking out tag '${tag_name}'..."
	git checkout -q "${tag_name}"
	echo "done."
}

function git_commit {
	local commit_msg="${1}"

	echo -n ">>>> Running 'git commit'..."
	git commit -a -m "${commit_msg}" -q
	echo "done."
}

function git_fetch_repo {
	local repo_name="${1}"

	check_param "${repo_name}" "Missing repo name"

	lc_cd "${BASE_DIR}"

	if [ -d "${repo_name}" ]
	then
		echo -n "Repository '${repo_name}' exists, refreshing..."
		lc_cd "${repo_name}"
		git fetch --all
		echo "done."

	else
		echo -n "Repository '${repo_name}' does not exists, cloning..."
		git clone "${GITHUB_ADDRESS}/${repo_name}"
		echo "done."
	fi
}

function git_fsck {
	echo -n ">>>> Running 'git fsck'..."

	if (! git fsck --full >/dev/null 2>&1)
	then
		echo "Running of 'git fsck' has failed."
		exit 1
	fi

	echo "done."
}

function git_gc {
	echo -n ">>>> Running 'git gc'..."

	while (pgrep -f "git gc" >/dev/null)
	do
		sleep 1
	done

	rm -f .git/gc.log

	git gc --quiet
	echo "done."
}

function git_get_all_tags {
	git tag -l --sort=creatordate --format='%(refname:short)' "${VERSION}*"
}

function git_get_new_tags {
	echo "Getting new tags... "

	lc_cd "${REPO_PATH_EE}"

	git_get_all_tags > "${TAGS_FILE_EE}"

	lc_cd "${REPO_PATH_DXP}"

	git_get_all_tags > "${TAGS_FILE_DXP}"

	local tag_name

	# shellcheck disable=SC2013
	for tag_name in $(cat "${TAGS_FILE_EE}")
	do
		if (! grep -qw "${tag_name}" "${TAGS_FILE_DXP}")
		then
			echo "${tag_name}"
		fi
	done

	echo "done."
}

function git_init_repo {
	if [ -d "${REPO_PATH_DXP}" ]
	then
		echo "DXP repo already exists: '${REPO_PATH_DXP}'"
		exit 1
	fi

	echo -n "Initializing repo ..."

	git init -q "${REPO_PATH_DXP}"

	lc_cd "${REPO_PATH_DXP}"

	touch README.md

	git_add

	git_commit "Initial commit"

	git remote add origin "${GITHUB_ADDRESS}/${REPO_NAME_DXP}"

	echo "done."
}

function git_pull_and_push_all_tags {
	git_get_new_tags > "${TAGS_FILE_NEW}"

	for version_minor in $(cat "${TAGS_FILE_NEW}" | cut -d "." -f2 | sort -nu)
	do
		local version_patch

		for version_patch in $(cat "${TAGS_FILE_NEW}" | grep "7.${version_minor}." | cut -d "." -f3 | cut -d "-" -f1 | sort -nu)
		do
			local version_semver
			version_semver="7.${version_minor}.${version_patch}"

			git_checkout_branch "${version_semver}"

			local version_full

			for version_full in $(cat "${TAGS_FILE_NEW}" | grep "${version_semver}")
			do
				git_pull_tag "${version_full}"
			done
		done
	done
}

function git_pull_tag {
	local tag_name="${1}"

	check_param "${tag_name}" "Missing tag name"

	echo

	echo "Pulling tag: ${tag_name} ..."

	lc_cd "${REPO_PATH_EE}"

	git_checkout_tag "${tag_name}"

	lc_cd "${REPO_PATH_DXP}"

	git_gc

	git_fsck

	run_rsync

	git_add

	git_commit "${tag_name}"

	git_tag "${tag_name}"

	echo "done."
}

function git_push_in_batches {
	local remote="${1}"
	local branch_name="${2}"
	local batch_size=100

	if git show-ref --quiet --verify "refs/remotes/${remote}/${branch_name}"
	then
		range="${remote}/${branch_name}..HEAD"
	else
		range="HEAD"
	fi

	packages=$(git log --first-parent --format=format:x "${range}" | wc -l)

	echo "Have to push ${packages} packages in range of ${range}"

	for batch_number in $(seq "${packages}" -"${batch_size}" 1)
	do
		batch_commit=$(git log --first-parent --format=format:%H -n1 --reverse --skip "${batch_number}")

		echo "Pushing ${batch_commit}..."

		git push -q "${remote}" "${batch_commit}:refs/heads/${branch_name}"
	done

	git push -q "${remote}" "HEAD:refs/heads/${branch_name}"
}

function git_push_repo {
	lc_cd "${REPO_PATH_DXP}"

	echo -n "Pushing all branches..."

	local branch_list
	branch_list=$(git for-each-ref --format='%(refname:short)' --sort=creatordate refs/heads/ | grep ^7)

	local branch_name

	for branch_name in ${branch_list}
	do
		git_checkout_branch "${branch_name}"

		git_push_in_batches origin "${branch_name}"
	done

	echo "done."

	echo -n "Pushing all tags..."
	git push -q --tags
	echo "done."
}

function git_tag {
	local tag_name="${1}"

	local commit_hash
	commit_hash=$(git rev-parse HEAD)

	echo -n ">>>> Running 'git tag'..."
	git tag "${tag_name}" "${commit_hash}"
	echo "done."
}

function run_rsync {
	echo -n ">>>> Running 'rsync'..."
	rsync -ar --delete --exclude '.git' "${REPO_PATH_EE}/" "${REPO_PATH_DXP}/"
	echo "done."
}

check_param "${VERSION}" "Missing version"

if [ "${RUN_FROM_SCRATCH}" == "true" ]
then
	lc_time_run git_init_repo "${REPO_NAME_DXP}"
else
	lc_time_run git_fetch_repo "${REPO_NAME_DXP}"
fi

lc_time_run git_fetch_repo "${REPO_NAME_EE}"

lc_time_run git_pull_and_push_all_tags

lc_time_run git_push_repo
