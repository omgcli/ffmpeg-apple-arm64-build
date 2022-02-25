#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = meson version

# load functions
. $1/functions.sh


SOFTWARE=meson

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
  curl -L -O "https://github.com/mesonbuild/meson/releases/download/$4/meson-$4.tar.gz"
  checkStatus $? "download of ${SOFTWARE} failed"

  tar -zxf "meson-$4.tar.gz"
  checkStatus $? "unpack meson failed"
  cd "meson-$4/"
  checkStatus $? "change directory failed"
}

make_clean() {
  if [ -h "$3/bin/meson" ]; then
    rm "$3/bin/meson"
    checkStatus $? "make clean for $SOFTWARE failed"
  fi
}

make_compile () {
  ln -s "$2/${SOFTWARE}/${SOFTWARE}-$4/meson.py" "$3/bin/meson"
  checkStatus $? "build of ${SOFTWARE} failed"
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
  fi

  make_clean $@
  make_compile $@

}

build_main $@
