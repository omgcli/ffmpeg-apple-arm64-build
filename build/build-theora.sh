#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = theora version

# load functions
. $1/functions.sh

SOFTWARE=libtheora

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

  fn="$SOFTWARE-$5.tar.bz2"

  # download source
  curl -O -L "http://downloads.xiph.org/releases/theora/$fn"
  checkStatus $? "download of ${SOFTWARE} failed"

  tar -xvf "$fn"
  checkStatus $? "unpack of ${SOFTWARE} failed"
}

configure_build () {

  cd "$2/${SOFTWARE}/${SOFTWARE}-$5/"
  checkStatus $? "change directory failed"

  # prepare build
  ./configure --prefix="$3" --disable-shared --enable-static --disable-dependency-tracking --disable-examples --disable-oggtest  --disable-vorbistest --disable-sdltest
  checkStatus $? "configuration of ${SOFTWARE} failed"

}

make_clean() {

  cd "$2/${SOFTWARE}/${SOFTWARE}-$5/"
  checkStatus $? "change directory failed"
  make clean

}

make_compile () {

  cd "$2/${SOFTWARE}/${SOFTWARE}-$5/"
  checkStatus $? "change directory failed"

  # build
  make -j $4
  checkStatus $? "build of ${SOFTWARE} failed"

  # install
  make install
  checkStatus $? "installation of ${SOFTWARE} failed"

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
