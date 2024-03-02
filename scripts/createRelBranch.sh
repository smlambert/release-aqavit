#!/usr/bin/env bash

workDir="$(pwd)"
aqavitGitTag=$1
allJDKVersionTags=$2
teFile="./testenv/testenv.properties"

usage ()
{
	echo 'Usage : createRelBranch.sh aqavitGitTag jdk22Tag,jdk21Tag,jdk17Tag,jdk11Tagjdk8Tag '
 	echo 'Usage : createRelBranch.sh v1.0.1 22.0.0,21.0.3,17.0.11,11.0.23,8u411 '
}

setProperty(){
  fileToChange=$3
  awk -v pat="^$1=" -v newval="$1=$2" '{ if ($0 ~ pat) print newval; else print $0; }' $fileToChange > $fileToChange.tmp
  mv $fileToChange.tmp $fileToChange
}

cd "${workDir}/aqa-tests"
echo "Working in $(pwd)"
git checkout -b "${gitTag}-release" "${aqavitGitTag}"

# Parse allJDKVersionTags into individual version tags
echo "2nd parameter is $allJDKVersionTags"
IFS=',' read -ra versionArray <<< "$allJDKVersionTags"

for i in "${versionArray[@]}"
do
    echo $i
    jdkVersion=${i:0:2}
    branchVal="jdk-${i}-ga"
    if [ $jdkVersion eq "8u" ]; then
	branchVal="jdk${i}-ga"
	jdkVersion="8"
    fi
    workingBranch="JDK${jdkVersion}_BRANCH"
    echo "Setting $workingBranch=$branchVal"
    setProperty $workingBranch $branchVal $teFile
done

echo "set the AQAvit tag in all testenv/testenv.properties"
for file in $teFile ./testenv/testenv_arm32.properties ./testenv/testenv_zos.properties ;
do
    echo "set the AQAvit tag in $file"
    setProperty "TKG_BRANCH" $aqavitGitTag $file
    setProperty "STF_BRANCH" $aqavitGitTag $file
    setProperty "ADOPTOPENJDK_SYSTEMTEST_BRANCH" $aqavitGitTag $file    
done

# Stage changes
git commit -m "Update testenv.properties"

# Push your newly created branch to remote repository.
#git push -u origin "${aqavitGitTag}-release"
