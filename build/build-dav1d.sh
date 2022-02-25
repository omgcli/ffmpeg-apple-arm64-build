#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = dav1d version

# load functions
. $1/functions.sh


SOFTWARE=dav1d

make_directories() {

  # start in working directory
  cd "$2"
  checkStatus $? "change directory failed"
  mkdir ${SOFTWARE}
  checkStatus $? "create directory failed"
  cd ${SOFTWARE}
  checkStatus $? "change directory failed"

}

download_code () {
  cd "$2/${SOFTWARE}"
  checkStatus $? "change directory failed"
  # download source
  curl -L -O "https://code.videolan.org/videolan/dav1d/-/archive/$5/dav1d-$5.tar.gz"
  checkStatus $? "download of ${SOFTWARE} failed"

  tar -zxf "dav1d-$5.tar.gz"
  checkStatus $? "unpack dav1d failed"
  cd "dav1d-$5/"
  checkStatus $? "change directory failed"
}

make_clean() {
  cd "$2/${SOFTWARE}/dav1d-$5/build"
  checkStatus $? "change to build directory failed"

  ninja uninstall
  checkStatus $? "uninstall of dav1d failed"

  ninja clean
  checkStatus $? "clean of dav1d failed"
}

configure_build () {
  cd "$2/${SOFTWARE}/dav1d-$5"
  checkStatus $? "change directory failed"

  # prepare build
  mkdir ./build
  checkStatus $? "create dav1d build directory failed"
  cd ./build
  checkStatus $? "change directory to dav1d build failed"

  meson --prefix "$3" --default-library=static ..
#  cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DCONFIG_RUNTIME_CPU_DETECT=no    -DENABLE_NEON=ON -DHAVE_NEON=1 -DENABLE_EXAMPLES=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-flto -O3" -DCMAKE_C_FLAGS="-flto -O3" -DCMAKE_C_FLAGS_INIT="-flto=8" ../aom/
  checkStatus $? "configuration of dav1d failed"
}

make_compile () {
  cd "$2/${SOFTWARE}/dav1d-$5/build"
  checkStatus $? "change directory failed"

  ninja -j "$4"
  checkStatus $? "compile of dav1d failed"

  ninja install
  checkStatus $? "install of dav1d failed"
}

build_main () {


set -x

  if [[ -d "$2/${SOFTWARE}" && "${ACTION}" == "skip" ]]
  then
      return 0
  elif [[ -d "$2/${SOFTWARE}" && -z "${ACTION}" ]]
  then
      echo "${SOFTWARE} build directory already exists but no action set. Exiting script"
      exit 0
  fi


  if [[ ! -d "$2/${SOFTWARE}" ]]
  then
    make_directories $@
    download_code $@
    configure_build $@
  fi

  make_clean $@
  make_compile $@

}

build_main $@
