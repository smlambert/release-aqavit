#!/usr/bin/env bash

workDir="$(pwd)"
gitTag="v0.9.8"

for repoName in "aqa-tests" "TKG" "aqa-systemtest" "aqa-test-tools" "STF" "bumblebench"
do
        repo="https://github.com/adoptium/${repoName}.git"
        echo "${repo}"
        git clone "${repo}"
        cd "${workDir}/${repoName}"
        git tag -a "${gitTag}" -m "${gitTag} tags"
        git push origin "${gitTag}"
        cd "${workDir}"
        echo ""
done