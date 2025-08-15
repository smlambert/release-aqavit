#!/usr/bin/env bash

workDir="$(pwd)"
gitTag=$1
reposToTag="${2//,/ }" # Replace commas with spaces
isDryRun=$3

usage ()
{
	echo 'Usage : tagRepos.sh gitTag setOfOrgReposToTag isDryRun[0|1]'
 	echo 'Usage : tagRepos.sh adoptium/aqa-tests,adoptium/TKG v1.0.0 0'
}

for orgAndRepoName in "${reposToTag}"
do
        repo="https://github.com/${orgAndRepoName}.git"
        echo "${repo}"
        git clone "${repo}"
		repoName="${orgAndRepoName##*/}"
        cd "${workDir}/${repoName}"
        git tag -a "${gitTag}" -m "${gitTag} tags"
	if [ $isDryRun -eq 0 ]; then
    		echo "Not pushing ${gitTag} to ${orgAndRepoName}"
	else
    		git push origin "${gitTag}"
	fi
        cd "${workDir}"
        echo ""
done
