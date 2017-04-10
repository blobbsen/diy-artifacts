#!/bin/bash

set -ex
source osmo-build.sh

genericDeps() {

	x="$($1 libosmocore master ac_cv_path_DOXYGEN=false)"
	x="${x}_$($1 libosmo-abis)"
	x="${x}_$($1 libosmo-netif)"
	x="${x}_$($1 libosmo-sccp)"
	x="${x}_$(PARALLEL_MAKE=-j1 $1 libsmpp34)"
	x="${x}_$($1 openggsn)"

	if [ "x$IU" = "x--enable-iu" ]; then
		x="${x}_$($1 libasn1c)"
		x="${x}_$($1 osmo-iuh)"
	fi

	echo "${x}.tar.gz"
}

buildProject() {

	cd "$base/openbsc"

	autoreconf --install --force

	./configure --enable-osmo-bsc \
		--enable-nat "$SMPP" "$MGCP" "$IU" \
		--enable-vty-tests \
	  --enable-enameternal-tests

	"$MAKE" "$PARALLEL_MAKE"
	"$MAKE" check || cat-testlogs.sh
	"$MAKE" distcheck || cat-testlogs.sh
}


build "openbsc" "useArtifact" #"$1"
