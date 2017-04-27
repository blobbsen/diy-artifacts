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
	echo "${jobName}_$1.tar.gz"
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

	if [ ! -f "$ARTIFACT_STORE/tmp/$artifact" ]; then
			mkdir -p "$ARTIFACT_STORE/tmp/"
			tar czf "$ARTIFACT_STORE/tmp/$artifact" "deps"
	fi

	rm -f "$ARTIFACT_STORE/$jobName*"
	mv -n "$ARTIFACT_STORE/tmp/$artifact" "$ARTIFACT_STORE/$artifact"
	rm -f "$ARTIFACT_STORE/tmp/$jobName*"

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
