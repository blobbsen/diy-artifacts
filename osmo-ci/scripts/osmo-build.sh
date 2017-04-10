#!/bin/bash

source osmo-artifacts.sh

initBuild() {
	base="$(pwd)"
	deps="$base/deps"
	inst="$deps/install"
  project="$1"

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

	mkdir "$deps" || true
	rm -rf "$inst"

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

  artifactDir="$ARTIFACT_STORE/$project"
  pathOfNeededArtifact="$artifactDir/$(getArtifactNameByRemoteRepos)"

  if [ ! -f "$pathOfNeededArtifact" ]; then
    buildDeps
    archiveArtifact "$artifactDir"
  else
    fetchArtifact "$pathOfNeededArtifact"
  fi

	set +x
	echo
	echo "[INFO] ======================== $project =========================="
	echo
	set -x

  buildProject
}
