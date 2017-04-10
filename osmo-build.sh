#!/bin/bash

source $(pwd)/contrib/osmo-artifacts.sh

initBuild() {
	base="$(pwd)"
	deps="$base/deps"
	inst="$deps/install"

	export base deps inst
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

	export project="$1"

	initBuild

	# TODO: artifactStore -> envVar
	artifactStore="/build_bin/artifactStore"
  projectArtifactDir="$artifactStore/$project"
  pathOfNeededArtifact="$projectArtifactDir/$(getArtifactNameByRemoteRepos)"

  if [ ! -f "$pathOfNeededArtifact" ]; then
    buildDeps
    archiveArtifact "$(getArtifactNameByLocalRepos)" "$projectArtifactDir"
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
