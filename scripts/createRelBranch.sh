#!/usr/bin/env bash

workDir="$(pwd)"
aqavitGitTag=$1
allJDKVersionTags=$2
teFile="./testenv/testenv.properties"

usage ()
{
	echo 'Usage : createRelBranch.sh aqavitGitTag jdk22Tag,jdk21Tag,jdk17Tag,jdk11Tagjdk8Tag '
 	echo 'Usage : createRelBranch.sh v1.0.1 22.0.1,21.0.3,17.0.11,11.0.23,8u411 '
}

setProperty(){
  awk -v pat="^$1=" -v newval="$1=$2" '{ if ($0 ~ pat) print newval; else print $0; }' $teFile > $teFile.tmp
  mv $teFile.tmp $teFile
}

cd "${workDir}/aqa-tests"
git checkout -b "${gitTag}-release" "${aqavitGitTag}"

# Parse allJDKVersionTags into individual version tags
echo "2nd parameter is $allJDKVersionTags"
IFS=';' read -ra versionArray <<< "$allJDKVersionTags"

for i in "${versionArray[@]}"
do
    echo $i
    jdkVersion=${i:0:2}
    workingBranch="JDK${jdkVersion}_BRANCH"
    setProperty $workingBranch $i
done

# Stage changes
git commit -m "Update testenv.properties"

# Push your newly created branch to remote repository.
git push -u origin "${aqavitGitTag}-release"
