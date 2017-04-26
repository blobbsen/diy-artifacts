#!/bin/bash

source osmo-artifacts.sh

initBuild() {
	base="$(pwd)"
	deps="$base/deps"
	inst="$deps/install"
  project="$1"

	mkdir "$deps" || true
	rm -rf "$inst"

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

  if [ -z "$1" ]; then
    echo
    echo "[ERROR] Please pass the name of the project when calling build"
    echo "        function within your jenkins.sh script e.g.:"
    echo
    echo "        build \"openbsc\""
    echo
  	exit 1
  fi

  initBuild "$1"

	# Jenkins variable
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
