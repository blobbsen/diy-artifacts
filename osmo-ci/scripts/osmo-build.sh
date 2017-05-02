#!/bin/bash

source osmo-artifacts.sh

initBuild() {

	if [ -z "$JOB_NAME" ]; then
		set +x
		echo
		echo "[ERROR] JOB_NAME variable is not set, running in Jenkins?"
		echo
		set -x
		exit 1
	fi

	base="$(pwd)"
	deps="$base/deps"
	inst="$deps/install"

  project=$(git config --get --local remote.origin.url \
			| cut -d '/' -f4 | cut -d '.' -f1)

	jobName="$(echo "$JOB_NAME" | sed 's/\//#/g')"

	export base deps inst project jobName
	export PKG_CONFIG_PATH="$inst/lib/pkgconfig:$PKG_CONFIG_PATH"
	export LD_LIBRARY_PATH="$inst/lib"
}

buildDeps() {
	set +x
	echo
	echo "[INFO] Compile $project dependencies from source."
	echo
	set -x

	mkdir -p "$deps"
	rm -rf "$inst"
	genericDeps "osmo-build-dep.sh"
}

build() {

	initBuild

	neededArtifact="$(getArtifactNameByRemoteRepos)"
  pathOfNeededArtifact="$ARTIFACT_STORE/$jobName/$neededArtifact"

  if [ -f "$pathOfNeededArtifact" ]; then
		fetchArtifact "$pathOfNeededArtifact"
  else
		buildDeps
		archiveArtifact
  fi

	set +x
	echo
	echo " ============================= $project =========================="
	echo
	set -x

  buildProject
}
