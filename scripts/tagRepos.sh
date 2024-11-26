#!/usr/bin/env bash

workDir="$(pwd)"
gitTag=$1

usage ()
{
	echo 'Usage : tagRepos.sh gitTag isDryRun[0|1]'
 	echo 'Usage : tagRepos.sh v1.0.0 0'
}

for repoName in "aqa-tests" "TKG" "aqa-systemtest" "aqa-test-tools" "STF" "bumblebench" "openj9-systemtest"
do
        repo="https://github.com/adoptium/${repoName}.git"
        echo "${repo}"
        git clone "${repo}"
        cd "${workDir}/${repoName}"
        git tag -a "${gitTag}" -m "${gitTag} tags"
	if [ $isDryRun -eq 0 ]; then
    		echo "Not pushing ${gitTag} to ${repoName}"
	else
    		git push origin "${gitTag}"
	fi
        cd "${workDir}"
        echo ""
done
