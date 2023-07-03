# release-aqavit
Scripts to assist prepping AQAvit releases

- Tag the AQAvit repos with the next release tag by running tagRepos.sh (NOTE: run-aqa does not need to be tagged, it follows a separate release process as per the Github action publishing guidelines).

- Create the release branch with the name based from the tag, update the testenv.properties file with tags expected to be used in the dry-run and/or release.

- Create a Github release based off the release tag used (and mark it as 'latest').
