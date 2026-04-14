#!/usr/bin/env bash

# Code assistance from IBM Bob

set -euo pipefail

gitTag=${1:-}
repoList="adoptium/aqa-tests"
isDryRun=${3:-1}
isPreRelease=${4:-0}

usage() {
	echo 'Usage : createRelease.sh gitTag'
	echo 'Usage : createRelease.sh v1.0.0'
}

if [ -z "${gitTag}" ] || [ -z "${repoList}" ]; then
	usage
	exit 1
fi

if [ "${isDryRun}" != "0" ] && [ "${isDryRun}" != "1" ]; then
	echo "Error: isDryRun must be 0 or 1"
	exit 1
fi

if [ "${isPreRelease}" != "0" ] && [ "${isPreRelease}" != "1" ]; then
	echo "Error: isPreRelease must be 0 or 1"
	exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
	echo "Error: GitHub CLI (gh) is required"
	exit 1
fi

IFS=',' read -r -a repos <<< "${repoList}"

for repo in "${repos[@]}"
do
	repo="$(echo "${repo}" | xargs)"
	echo "Preparing release for ${repo}"

	if ! git ls-remote --tags "https://github.com/${repo}.git" "refs/tags/${gitTag}" | grep -q "${gitTag}"; then
		echo "Error: tag ${gitTag} does not exist in ${repo}"
		exit 1
	fi

	releaseArgs=(release create "${gitTag}" --repo "${repo}" --title "${gitTag}" --generate-notes --latest)

	if [ "${isPreRelease}" -eq 1 ]; then
		releaseArgs+=(--prerelease)
	fi

	if [ "${isDryRun}" -eq 1 ]; then
		echo "Dry run: gh ${releaseArgs[*]}"
	else
		gh "${releaseArgs[@]}"
	fi

	echo ""
done


