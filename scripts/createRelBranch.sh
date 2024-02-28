#!/usr/bin/env bash

workDir="$(pwd)"
aqavitGitTag=$1
allJDKVersionTags=$2
teFile="./testenv/testenv.properties"
jdk22Tag=""
jdk21Tag=""
jdk17Tag=""
jdk11Tag=""
jdk8Tag=""

usage ()
{
	echo 'Usage : createRelBranch.sh aqavitGitTag jdk22Tag,jdk21Tag,jdk17Tag,jdk11Tagjdk8Tag '
 	echo 'Usage : createRelBranch.sh v1.0.1 22.0.1,21.0.3,17.0.11,11.0.23,8u411 '
}

setProperty(){
  awk -v pat="^$1=" -v newval="$1=$2" '{ if ($0 ~ pat) print newval; else print $0; }' $teFile > $teFile.tmp
  mv $teFile.tmp $teFile
}

# Parse allJDKVersionTags into individual version tags TODO

# cd "${workDir}/aqa-tests"
git checkout -b "${gitTag}-release" "${aqavitGitTag}"

# Make changes to testenv/testenv.properties file
setProperty JDK8_BRANCH $jdk8Tag
setProperty JDK11_BRANCH $jdk11Tag
setProperty JDK17_BRANCH $jdk17Tag
setProperty JDK21_BRANCH $jdk21Tag
setProperty JDK22_BRANCH $jdk22Tag

# Stage changes
git commit -m "Update testenv.properties"

# Push your newly created branch to remote repository.
git push -u origin "${aqavitGitTag}-release"
