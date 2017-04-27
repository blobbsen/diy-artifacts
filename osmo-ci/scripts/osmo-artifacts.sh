#!/bin/bash
#
# documentation.
#
#

# determining artifact name
getArtifactNameByLocalRepos(){
	genericDeps "getBranchAndRevByLocalRepo"
	cd "$base"
}

getArtifactNameByRemoteRepos() {
	genericDeps "getBranchAndRevByRemoteRepo"
}

getBranchAndRevByLocalRepo() {
	cd "$deps/$1"
	rev=$(git rev-parse --short HEAD)
	branch=$(git rev-parse --abbrev-ref HEAD)
	echo "$1.${branch//\//#}.${rev}"
}

getBranchAndRevByRemoteRepo() {
	if [ -z "${2+x}" ]; then branch="master"; else branch="$2"; fi
	rev=$(git ls-remote "https://git.osmocom.org/$1" "refs/heads/$branch")
	echo "$1.${branch//\//#}.${rev:0:7}"
}

finalizeArtifactName(){
	finalArtifactName="$(echo $JOB_NAME | 's/\//#/g')"
	echo "${finalArtifactName}.tar.gz"
}

# file handling
archiveArtifact() {
	set +x
	echo
	echo "[INFO] Archiving artifact to artifactStore."
	echo
	set -x

	cd "$base"
	artifact="$(getArtifactNameByLocalRepos)"

	projectStorage="$ARTIFACT_STORE/$jobArtifactDir"
	tempProjectStorage="$ARTIFACT_STORE/tmp/$jobArtifactDir"

	if [ ! -f "$tempProjectStorage/$artifact" ]; then
			mkdir -p "$tempProjectStorage"
			tar czf "$tempProjectStorage/$artifact" "deps"
	fi

  mkdir -p "$projectStorage"
	rm -f "$projectStorage/*"
	mv -n "$tempProjectStorage/$artifact" "$projectStorage/$artifact"
	rm -f "$tempProjectStorage/$artifact"

	generateArtifactHashes "$projectStorage/$artifact"
}

fetchArtifact() {
  set +x
  echo
  echo "[INFO] Fetching artifact from artifactStore."
  echo
  set -x

  generateArtifactHashes "$1"
  tar xzf "$1" # "$base"
}

generateArtifactHashes() {
	set +x
	echo
	echo "[INFO] name: $1"
	echo "[INFO] md5: $(md5sum "$1" | cut -d' ' -f1)"
	echo "[INFO] sha1: $(sha1sum "$1" | cut -d' ' -f1)"
	echo "[INFO] sha256: $(sha256sum "$1" | cut -d' ' -f1)"
	echo
	set -x
	sleep 1
}
