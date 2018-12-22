#!/bin/bash -e

set -e

echo This script downloads the code for the benchmarks
echo It will also attempt to build the benchmarks
echo It will output OK at the end if builds succeed
echo

IOR_HASH=1b28a64234751e4ef1672360a8bc19668b30ace9
MDREAL_HASH=f1f4269666bc58056a122a742dc5ca13be5a79f5

INSTALL_DIR=$PWD
BIN=$INSTALL_DIR/bin
BUILD=$PWD/build
MAKE="make -j4"

function setup {
  rm -rf $BUILD
  mkdir -p $BUILD $BIN
}

function git_co {
  pushd $BUILD
  git clone $1
  cd $2
  git checkout $3
  popd
}

###### GET FUNCTIONS
function get_ior {
  echo "Getting IOR and mdtest"
  git_co https://github.com/hpc/ior.git ior $IOR_HASH
  pushd $BUILD/ior
  ./bootstrap
  ./configure --prefix=$INSTALL_DIR
  popd
}

function get_pfind {
  echo "Preparing parallel find"
  pushd $BUILD
  # this is the new C pfind
  git clone https://github.com/VI4IO/pfind.git
  echo "Pfind: OK"
  echo
  popd
}

###### BUILD FUNCTIONS
function build_ior {
  pushd $BUILD
  cd ior/src # just build the source
  $MAKE install
  echo "IOR: OK"
  echo
  popd
}

function build_pfind {
  pushd $BUILD
  cd pfind
  ./prepare.sh
  ./compile.sh
  cp pfind $BIN
  echo "Pfind: OK"
  echo
  popd
}

function build_mdrealio {
  cd $BUILD/md-real-io
  pushd build
  $MAKE install
  #mv src/md-real-io $BIN
  echo "MD-REAL-IO: OK"
  echo
  popd
}

# main
setup

get_ior
get_pfind

build_ior
build_pfind

echo
echo "OK: All required software packages are now prepared"
ls $BIN
