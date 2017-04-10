#!/bin/bash

set -ex
source osmo-build.sh

genericDeps() {
  x="$($1 libosmocore master ac_cv_path_DOXYGEN=false)"
	"$deps"/libosmocore/contrib/verify_value_string_arrays_are_terminated.py $(find . -name "*.[hc]")
	x="${x}_$($1 libosmo-abis)"
	x="${x}_$($1 libosmo-netif)"

  echo "${x}.tar.gz"
}

buildProject() {
  autoreconf --install --force
  ./configure
  $MAKE $PARALLEL_MAKE
  $MAKE distcheck || cat-testlogs.sh
}

build libosmo-sccp
