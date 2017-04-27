#!/bin/bash

set -ex
source osmo-build.sh

genericDeps() {

	x="$($1 libosmocore master ac_cv_path_DOXYGEN=false)"
	"$deps"/libosmocore/contrib/verify_value_string_arrays_are_terminated.py $(find . -name "*.[hc]")
	x="${x}_$($1 libosmo-abis)"
	x="${x}_$($1 libosmo-netif)"
	x="${x}_$($1 libosmo-sccp)"
	x="${x}_$(PARALLEL_MAKE=-j1 $1 libsmpp34)"
	x="${x}_$($1 openggsn)"

	if [ "x$IU" = "x--enable-iu" ]; then
		x="${x}_$($1 libasn1c)"
		x="${x}_$($1 osmo-iuh)"
	fi

	#x="${x}_$(<parallel make> $1 <git-repo> <git-branch:master> <configure>)"
	finalizeArtifactName "$x"
}

buildProject() {

	cd "$base/openbsc"

	autoreconf --install --force

	./configure "$SMPP" "$MGCP" "$IU" \
		--enable-osmo-bsc \
		--enable-nat  \
		--enable-vty-tests \
	  --enable-external-tests

	"$MAKE" "$PARALLEL_MAKE"
	"$MAKE" check || cat-testlogs.sh
	"$MAKE" distcheck || cat-testlogs.sh
}

build
