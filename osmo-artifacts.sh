#!/bin/bash

getBranchAndRevByRemoteRepo() {
	# optional branch argument
	if [ -z "${2+x}" ]; then branch="master"; else branch="$2"; fi
	rev=$(git ls-remote "https://git.osmocom.org/$1" "refs/heads/$branch")
	echo "$1.${branch//\//#}.${rev:0:7}"
}

getBranchAndRevByLocalRepo() {
	cd "$deps/$1"
	rev=$(git rev-parse HEAD)
	branch=$(git rev-parse --abbrev-ref HEAD)
	echo "$1.${branch//\//#}.${rev:0:7}"
}

getArtifactNameByLocalRepos(){
	artifactName "getBranchAndRevByLocalRepo"
	cd "$base"
}

getArtifactNameByRemoteRepos() {
	# artifactName needs to be implemented within project specific jenkins.sh!
	artifactName "getBranchAndRevByRemoteRepo"
}

fetchOrBuilAndArchiveDeps() {
	if [ ! -f "$1" ]; then
		buildProjectDeps
		archiveArtifact "$(getArtifactNameByLocalRepos)" "$2"
	else
		fetchArtifact "$1"
	fi
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

fetchArtifact() {
  set +x
  echo
  echo "[INFO] Fetching artifact from artifactStore."
  echo
  set -x
  generateArtifactHashes "$1"
  tar xzf "$1" # "$base"
}

archiveArtifact() {
	set +x
	echo
	echo "[INFO] Archiving artifact to artifactStore."
	echo
	set -x
	cd "$base"
	tar czf "$1" "deps"
	generateArtifactHashes "$1"
  mkdir -p "$2"
	mv -n "$1" "$2"
}

initBuild() {
	base="$(pwd)"
	deps="$base/deps"
	inst="$deps/install"

	export base deps inst
	export PKG_CONFIG_PATH="$inst/lib/pkgconfig:$PKG_CONFIG_PATH"
	export LD_LIBRARY_PATH="$inst/lib"
}

build() {

	export project="$1"
	initBuild

	if [ "$2" = "useArtifact" ]; then
		# TODO: think about whether Docker volume would be suitable + envVar
		artifactStore="/build_bin/artifactStore"

  	projectArtifactDir="$artifactStore/$project"
  	pathOfNeededArtifact="$projectArtifactDir/$(getArtifactNameByRemoteRepos)"

    fetchOrBuilAndArchiveDeps "$pathOfNeededArtifact" "$projectArtifactDir"
  else
  	buildProjectDeps
	fi

  buildProject
}
