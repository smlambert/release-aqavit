#!/usr/bin/env bash

set -euo pipefail

workDir="$(pwd)"
gitTag=${1:-}
isDryRun=${2:-1}
defaultRepos=("aqa-tests" "TKG" "aqa-systemtest" "aqa-test-tools" "STF" "bumblebench" "openj9-systemtest")

usage ()
{
	echo 'Usage : tagRepos.sh gitTag isDryRun[0|1] [repo1,repo2,...]'
 	echo 'Usage : tagRepos.sh v1.0.0 0'
}

if [ -z "${gitTag}" ]; then
	usage
	exit 1
fi

if [ "${isDryRun}" != "0" ] && [ "${isDryRun}" != "1" ]; then
	echo "Error: isDryRun must be 0 or 1"
	usage
	exit 1
fi

repoList=${3:-$(IFS=,; echo "${defaultRepos[*]}")}
IFS=',' read -r -a repos <<< "${repoList}"

for repoName in "${repos[@]}"
do
	repoName="$(echo "${repoName}" | xargs)"
	repo="https://github.com/adoptium/${repoName}.git"
	echo "${repo}"
	git clone "${repo}"
	cd "${workDir}/${repoName}"
	git tag -a "${gitTag}" -m "${gitTag} tags"
	if [ "${isDryRun}" -eq 1 ]; then
		echo "Not pushing ${gitTag} to ${repoName}"
	else
		git push origin "${gitTag}"
	fi
	cd "${workDir}"
	echo ""
done
