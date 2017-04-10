#!/bin/bash

set -ex
source osmo-build.sh

genericDeps() {
	# Specify dependencies in the following way:
	#
	#	   		x="$($1 libosmocore master ac_cv_path_DOXYGEN=false)"
	#		  	x="${x}_$(PARALLEL_MAKE=-j1 $1 libosmo-abis)"
  #				.
	#				.
	#
  #				echo "${x}.tar.gz"
	#
	# Note: The following parameter can be adjust within the genericDeps function:
	#
	#				x="${x}_$(<PARALLEL_MAKE> $1 <DEPENDENCY> <BRANCH_TO_BUILD> <CFG>"
  #
	#				Furthermore, $1 represents the following script/functions:
	#					- osmo-build-dep.sh 							(osmo-build.sh)
	#					- getArtifactNameByLocalRepos()   (osmo-artifacts.sh)
	#					- getArtifactNameByRemoteRepos()  (osmo-artifacts.sh)
}

buildProject() {
	# Necessary commands to build the project.
}

build <PUT_NAME_OF_PROJECT_HERE>
