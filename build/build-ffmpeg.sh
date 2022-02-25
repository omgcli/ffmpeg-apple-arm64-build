#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = output directory
# $5 = CPUs
# $6 = FFmpeg version

# load functions
. $1/functions.sh

SOFTWARE=ffmpeg

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

  # make snapshot folder name consistent with releases
  if [ "$6" == "snapshot" ]; then
    git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg-snapshot
  else
    # download source
    curl -O https://ffmpeg.org/releases/ffmpeg-$6.tar.bz2
    checkStatus $? "download of ${SOFTWARE} failed"

    # unpack ffmpeg
    bunzip2 ffmpeg-$6.tar.bz2
    tar -xf ffmpeg-$6.tar
  fi

  cd "ffmpeg-$6/"
  checkStatus $? "change directory failed"
}

update_snapshot () {
  if [ "$6" == "snapshot" ]; then
    cd "$2/${SOFTWARE}/ffmpeg-snapshot"
    checkStatus $? "change directory failed"

    git pull
    checkStatus $? "git pull failed"
  fi
}

configure_build () {
  cd "$2/${SOFTWARE}/ffmpeg-$6/"
  checkStatus $? "change directory failed"

  # prepare build
  FF_FLAGS="-L${3}/lib -I${3}/include"
  export LDFLAGS="$FF_FLAGS"
  export CFLAGS="$FF_FLAGS"
  
  # --pkg-config-flags="--static" is required to respect the Libs.private flags of the *.pc files
  # --enable-libfdk-aac requires --enable-nonfree
  ./configure --prefix="$4" --enable-gpl --enable-nonfree --pkg-config-flags="--static" --pkg-config=$3/bin/pkg-config \
      --enable-libaom --enable-libopenh264 --enable-libx264 --enable-libx265 --enable-libvpx --enable-libtheora \
      --enable-libmp3lame --enable-libfdk-aac --enable-libopus --enable-neon --enable-runtime-cpudetect \
      --enable-audiotoolbox --enable-videotoolbox --enable-libvorbis --enable-libsvtav1 --enable-libdav1d \
      --enable-libass --enable-lto --enable-opencl

  checkStatus $? "configuration of ${SOFTWARE} failed"
}

make_clean() {
  cd "$2/${SOFTWARE}/ffmpeg-$6/"
  checkStatus $? "change directory failed"
  make clean
  checkStatus $? "make clean for $SOFTWARE failed"
}

make_compile () {
  cd "$2/${SOFTWARE}/ffmpeg-$6/"
  checkStatus $? "change directory failed"

  # build
  make -j $5
  checkStatus $? "build of ${SOFTWARE} failed"

  # install
  make install
  checkStatus $? "installation of ${SOFTWARE} failed"
}

build_main () {
  # ffmpeg we always want to rebuild
  if [[ ! -d "$2/${SOFTWARE}" ]]
  then
    make_directories $@
    download_code $@
    configure_build $@
  fi

  make_clean $@
  update_snapshot $@
  configure_build $@
  make_compile $@
}

build_main $@
