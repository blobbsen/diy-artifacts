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
  # TODO: artifactStore -> envVar
  ARTIFACT_STORE="/build_bin/artifactStore"

  initBuild
	export project="$1"

  projectArtifactDir="$ARTIFACT_STORE/$project"
  pathOfNeededArtifact="$projectArtifactDir/$(getArtifactNameByRemoteRepos)"

  if [ ! -f "$pathOfNeededArtifact" ]; then
    buildDeps
    archiveArtifact "$projectArtifactDir"
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
