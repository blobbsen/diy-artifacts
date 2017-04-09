#!/bin/bash

buildProjectDeps() {
	osmo-build-dep.sh libosmocore "" ac_cv_path_DOXYGEN=false
	osmo-build-dep.sh libosmo-abis
	osmo-build-dep.sh libosmo-netif
	osmo-build-dep.sh libosmo-sccp
	PARALLEL_MAKE="-j1" osmo-build-dep.sh libsmpp34
	osmo-build-dep.sh openggsn

	if [ "x$IU" = "x--enable-iu" ]; then
		osmo-build-dep.sh libasn1c
		#osmo-build-dep.sh asn1c aper-prefix # only needed for make regen in osmo-iuh
		osmo-build-dep.sh osmo-iuh
	fi
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

artifactName() {

	# $1 represents functions determining artifactName within osmo-artifacts.sh.
	# Note: it must be a name of a git repository
	name="$($1 libosmocore)"
	name="${name}_$($1 libosmo-abis)"
	name="${name}_$($1 libosmo-netif)"
	name="${name}_$($1 libosmo-sccp)"
	name="${name}_$($1 libsmpp34)"
	name="${name}_$($1 openggsn)"

	if [ "x$IU" = "x--enable-iu" ]; then
		name="${name}_$($1 libasn1c)"
		name="${name}_$($1 osmo-iuh)"
	fi

	echo "${name}.tar.gz"
}

set -ex
. osmo-artifacts.sh
build openbsc "$1"
