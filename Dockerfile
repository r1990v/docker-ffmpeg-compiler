FROM ubuntu:16.04

# Container for compiling ffmpeg and copying ffmpeg, ffprobe, and ffserver to the host operating system.
# If the host OS is not linux, another container could instead use the binary.

# Example build
# docker build -t ffmpeg-compiler .

# Example run
# docker run --rm -it -v $(pwd):/host ffmpeg-compiler bash -c "cp /root/bin/ffmpeg /root/bin/ffprobe /root/bin/ffserver /host && chown $(id -u):$(id -g) /host/ffmpeg && chown $(id -u):$(id -g) /host/ffprobe && chown $(id -u):$(id -g) /host/ffserver"

MAINTAINER rvats

# Get the dependencies
RUN set -x \
&& apt-get update \
&& apt-get -y install wget git curl autoconf automake build-essential libass-dev libfreetype6-dev \
  libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
  libxcb-xfixes0-dev pkg-config texinfo zlib1g-dev \
&& mkdir ~/ffmpeg_sources \
&& apt-get -y install yasm \
&& cd ~/ffmpeg_sources \
&& wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz \
&& tar xzvf yasm-1.3.0.tar.gz \
&& cd yasm-1.3.0 \
&& ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" \
&& make -j$(cat /proc/cpuinfo | grep processor | wc -l) \
&& make install \
&& make distclean \
&& apt-get -y install libx264-dev \
&& apt-get -y install cmake mercurial \
&& ls $HOME/ffmpeg_build \
&& echo COMPLETED PART 1

RUN set -x \
&& cd ~/ffmpeg_sources \
&& hg --version \
&& hg clone https://bitbucket.org/multicoreware/x265 \
&& cd ~/ffmpeg_sources/x265/build/linux \
&& PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source \
&& make -j$(cat /proc/cpuinfo | grep processor | wc -l) \
&& make install \
&& make clean \
&& cd ~/ffmpeg_sources \
&& wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master \
&& tar xzvf fdk-aac.tar.gz \
&& cd mstorsjo-fdk-aac* \
&& autoreconf -fiv \
&& ./configure --prefix="$HOME/ffmpeg_build" --disable-shared \
&& make -j$(cat /proc/cpuinfo | grep processor | wc -l) \
&& make install \
&& make distclean \
&& ls $HOME/ffmpeg_build \
&& echo COMPLETED PART 2

RUN set -x \
&& echo install libmp3lame \
&& apt-get -y install libmp3lame-dev \
&& apt-get -y install libopus-dev \
&& cd ~/ffmpeg_sources \
&& wget https://github.com/webmproject/libvpx/archive/v1.8.2.tar.gz \
&& tar xzvf v1.8.2.tar.gz \
&& cd libvpx-1.8.2 \
&& PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests \
&& PATH="$HOME/bin:$PATH" make -j$(cat /proc/cpuinfo | grep processor | wc -l) \
&& make install \
&& make clean \
&& ls $HOME/ffmpeg_build/bin

#install ffmpeg
RUN cd ~/ffmpeg_sources \
&& git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg \
&& cd ffmpeg \
&& PATH="$HOME/bin:$PATH" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --bindir="$HOME/bin" \
&& PATH="$HOME/bin:$PATH" \
&& make install \
&& make distclean \
&& ls $HOME/ffmpeg_build/bin \
&& hash -r
