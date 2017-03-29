#!/bin/bash

buildProjectDeps() {
	# code to build all dependencies.
}

buildProject() {
	# code to build project assuming all dependencies are available.
}

artifactName() {
	# $1 represents functions getBranchAndRevBy(Local||Remote)Repo determining
	# artifactName. These functions live within osmo-artifacts.sh.
	# Note: $1 must be a name of a git repository

	#example:
	name="$($1 <REPOSITORY>)" # master is default branch
	name="${name}_$($1 <REPOSITORY> <BRANCH>)"

	echo "${name}.tar.gz"
}

set -ex
. osmo-artifacts.sh
build <PROJECT> "$1"

# <PROJECT> is used for the project's artifactDir and for several log msgs,
# probably the project name suits best (e.g. "openbsc", "$(basename $(pwd))" ).
#
# "$1" must be "useArtifact" to activate builds fetching/archiving artifacts.
# This argument should be passed at invocation.
