#!/usr/bin/env bash

set -euo pipefail

workDir="$(pwd)"
aqavitGitTag=${1:-}
allJDKVersionTags=${2:-}
isDryRun=${3:-1}
teFile="./testenv/testenv.properties"

usage ()
{
	echo 'Usage : createRelBranch.sh aqavitGitTag jdk22Tag,jdk21Tag,jdk17Tag,jdk11Tag,jdk8Tag isDryRun[0|1]'
 	echo 'Usage : createRelBranch.sh v1.0.1 22.0.0,21.0.3,17.0.11,11.0.23,8u411 0'
}

setProperty(){
  local propertyName=$1
  local propertyValue=$2
  local fileToChange=$3
  awk -v pat="^${propertyName}=" -v newval="${propertyName}=${propertyValue}" '{ if ($0 ~ pat) print newval; else print $0; }' "${fileToChange}" > "${fileToChange}.tmp"
  mv "${fileToChange}.tmp" "${fileToChange}"
}

if [ -z "${aqavitGitTag}" ] || [ -z "${allJDKVersionTags}" ]; then
	usage
	exit 1
fi

if [ "${isDryRun}" != "0" ] && [ "${isDryRun}" != "1" ]; then
	echo "Error: isDryRun must be 0 or 1"
	usage
	exit 1
fi

if [ ! -d "${workDir}/aqa-tests" ]; then
	echo "Error: ${workDir}/aqa-tests does not exist"
	exit 1
fi

cd "${workDir}/aqa-tests"
echo "Working in $(pwd)"

for file in "${teFile}" ./testenv/testenv_arm32.properties ./testenv/testenv_zos.properties
do
	if [ ! -f "${file}" ]; then
		echo "Error: ${file} does not exist"
		exit 1
	fi
done

git checkout -b "${aqavitGitTag}-release" "${aqavitGitTag}"

# Parse allJDKVersionTags into individual version tags
echo "2nd parameter is ${allJDKVersionTags}"
IFS=',' read -ra versionArray <<< "${allJDKVersionTags}"

for i in "${versionArray[@]}"
do
    echo "${i}"
    jdkVersion=${i:0:2}
    branchVal="jdk-${i}-ga"
    if [ "${jdkVersion}" == "8u" ]; then
	branchVal="jdk${i}-ga"
	jdkVersion="8"
    fi
    workingBranch="JDK${jdkVersion}_BRANCH"
    echo "Setting ${workingBranch}=${branchVal}"
    setProperty "${workingBranch}" "${branchVal}" "${teFile}"
done

echo "set the AQAvit tag in all testenv/testenv.properties"
for file in "${teFile}" ./testenv/testenv_arm32.properties ./testenv/testenv_zos.properties
do
    echo "set the AQAvit tag in ${file}"
    setProperty "TKG_BRANCH" "${aqavitGitTag}" "${file}"
    setProperty "STF_BRANCH" "${aqavitGitTag}" "${file}"
    setProperty "ADOPTOPENJDK_SYSTEMTEST_BRANCH" "${aqavitGitTag}" "${file}"
done

# Stage changes
git add "${teFile}" ./testenv/testenv_arm32.properties ./testenv/testenv_zos.properties
git commit -m "Update testenv.properties"

# Push your newly created branch to remote repository.
if [ "${isDryRun}" -eq 1 ]; then
    echo "Not pushing changes to ${aqavitGitTag}-release"
else
    git push -u origin "${aqavitGitTag}-release"
fi

