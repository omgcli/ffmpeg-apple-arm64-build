#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = rav1e version

# load functions
. $1/functions.sh


SOFTWARE=rav1e

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
  git clone --depth 1 https://github.com/xiph/rav1e.git
  checkStatus $? "download of ${SOFTWARE} failed"

  cd "rav1e"
  checkStatus $? "change directory failed"
}

make_clean() {
  return 0
}

configure_build () {
  return 0
}

make_compile () {
  cd "$2/${SOFTWARE}/rav1e"
  checkStatus $? "change directory failed"

  RUSTFLAGS="-C target-cpu=native" cargo cinstall --prefix="$3" --library-type=staticlib --release --jobs "$4"
  checkStatus $? "install of rav1e failed"
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
