#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = fdk-aac version

# load functions
. $1/functions.sh

SOFTWARE=fdk-aac

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
  sourceFileName="${SOFTWARE}-$5.tar.gz"
  curl -L -o "$sourceFileName" "https://sourceforge.net/projects/opencore-amr/files/fdk-aac/$sourceFileName/download"
  checkStatus $? "download of ${SOFTWARE} failed"

  tar xf "$sourceFileName"
  checkStatus $? "download of ${SOFTWARE} failed"
}

configure_build () {

  cd "$2/${SOFTWARE}/${SOFTWARE}-$5"
  checkStatus $? "change directory failed"

  # prepare build
  LDFLAGS="-L$3/lib"  ./configure --prefix="$3" --enable-static --disable-shared --enable-pic --disable-dependency-tracking
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
