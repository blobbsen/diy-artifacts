#!/bin/bash

set -ex
source osmo-build.sh

genericDeps() {

	x="$($1 libosmocore master ac_cv_path_DOXYGEN=false)"
	"$deps"/libosmocore/contrib/verify_value_string_arrays_are_terminated.py $(find . -name "*.[hc]")
	x="${x}_$($1 libosmo-abis)"
	x="${x}_$($1 libosmo-netif sysmocom/sctp)"
	x="${x}_$($1 libosmo-sccp sysmocom/iu)"
	x="${x}_$($1 libasn1c)"
	x="${x}_$($1 asn1c aper-prefix)"

	echo "${x}.tar.gz"
}

buildProject() {

	autoreconf --install --force
	./configure

	# Verify that checked-in asn1 code is identical to regenerated asn1 code
	PATH="$inst/bin:$PATH" $MAKE $PARALLEL_MAKE -C src regen

	# attempt to settle the file system
	sleep 1

	git status
	git diff | cat

	if ! git diff-files --quiet ; then
	        echo "ERROR: 'make -C src regen' does not match committed asn1 code"
	        exit 1
	fi

	$MAKE $PARALLEL_MAKE
	$MAKE check || cat-testlogs.sh
	$MAKE distcheck || cat-testlogs.sh
}

build osmo-iuh
