#!/bin/bash

set -ex
source osmo-build.sh

genericDeps() {
  x="$($1 libosmocore master ac_cv_path_DOXYGEN=false)"
  "$deps"/libosmocore/contrib/verify_value_string_arrays_are_terminated.py $(find . -name "*.[hc]")

  echo "${x}.tar.gz"
}

buildProject() {
  setup

  autoreconf --install --force
  ./configure $PCU_CONFIG
  $MAKE $PARALLEL_MAKE

  DISTCHECK_CONFIGURE_FLAGS="$PCU_CONFIG" \
    AM_DISTCHECK_CONFIGURE_FLAGS="$PCU_CONFIG" \
    $MAKE distcheck || cat-testlogs.sh

}

setup() {
    # Collect configure options for osmo-pcu
  PCU_CONFIG=""
  if [ "$with_dsp" = sysmo ]; then
    PCU_CONFIG="$PCU_CONFIG --enable-sysmocom-dsp"

    # For direct sysmo DSP access, provide the SysmoBTS Layer 1 API
    cd "$deps"
    if [ ! -d layer1-api ]; then
      git clone git://git.sysmocom.de/sysmo-bts/layer1-api.git layer1-api
    fi
    cd layer1-api
    git fetch origin
    git reset --hard origin/master
    api_incl="$inst/include/sysmocom/femtobts/"
    mkdir -p "$api_incl"
    cp include/*.h "$api_incl"
    cd "$base"

  elif [ -z "$with_dsp" -o "$with_dsp" = none ]; then
    echo "Direct DSP access disabled"
  else
    echo 'Invalid $with_dsp value:' $with_dsp
    exit 1
  fi

  if [ "$with_vty" = "yes" ]; then
    PCU_CONFIG="$PCU_CONFIG --enable-vty-tests"
  elif [ -z "$with_vty" -o "$with_vty" = "no" ]; then
    echo "VTY tests disabled"
  else
    echo 'Invalid $with_vty value:' $with_vty
    exit 1
  fi
}

build osmo-pcu
