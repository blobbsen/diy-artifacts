#!/bin/bash

source osmo-artifacts.sh

initBuild() {
	base="$(pwd)"
	deps="$base/deps"
	inst="$deps/install"
  project=$(git config --get --local remote.origin.url \
			| cut -d '/' -f4 | cut -d '.' -f1)

	mkdir "$deps" || true
	rm -rf "$inst" # TODO: check this!

	export base deps inst project
	export PKG_CONFIG_PATH="$inst/lib/pkgconfig:$PKG_CONFIG_PATH"
	export LD_LIBRARY_PATH="$inst/lib"
}

buildDeps() {
	set +x
	echo
	echo "[INFO] Compile $project dependencies from source."
	echo
	set -x

	genericDeps "osmo-build-dep.sh"
}

build() {
  # TODO: artifactStore -> envVar
  ARTIFACT_STORE="/build_bin/artifactStore"
	
	initBuild

	# JOB_NAME is an environment variable injected by Jenkins
	jobArtifactDir="$(echo $JOB_NAME | 's/\//#/g')"
	neededArtifact="$(getArtifactNameByRemoteRepos)"
  pathOfNeededArtifact="$ARTIFACT_STORE/$jobArtifactDir/$neededArtifact"

  if [ -f "$pathOfNeededArtifact" ]; then
		fetchArtifact "$pathOfNeededArtifact"
  else
		buildDeps
		archiveArtifact "$jobArtifactDir"
  fi

	set +x
	echo
	echo " ============================= $project =========================="
	echo
	set -x

  buildProject
}
