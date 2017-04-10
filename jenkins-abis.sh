#!/bin/bash

set -ex
source osmo-build.sh

genericDeps() {
  x="$($1 libosmocore master ac_cv_path_DOXYGEN=false)"
  "$deps"/libosmocore/contrib/verify_value_string_arrays_are_terminated.py $(find . -name "*.[hc]")

  echo "${x}.tar.gz"
}

buildProject() {
  autoreconf --install --force
  ./configure --enable-sanitize
  $MAKE $PARALLEL_MAKE
  $MAKE distcheck || cat-testlogs.sh
}

build libosmo-abis
