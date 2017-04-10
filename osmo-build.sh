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

fetchOrBuilAndArchiveDeps() {
	if [ ! -f "$1" ]; then
		buildDeps
		archiveArtifact "$(getArtifactNameByLocalRepos)" "$2"
	else
		fetchArtifact "$1"
	fi
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
  	buildDeps
	fi

	set +x
	echo
	echo "[INFO] ======================== $project =========================="
	echo
	set -x
  buildProject
}
