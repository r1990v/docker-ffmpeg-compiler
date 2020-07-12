#!/usr/bin/env bash
#
# Script to fetch the source code for docker-ffmpeg-compiler, build the image, copy the relevant binaries to the current working directory, and delete the image.
#
#git clone https://github.com/r1990v/docker-ffmpeg-compiler.git
#cd docker-ffmpeg-compiler
docker build -t ffmpeg-compiler .
docker run --rm -it -v $(pwd):/host ffmpeg-compiler bash -c "cp /root/bin/ffmpeg /root/bin/ffprobe /root/bin/ffplay /host && chown $(id -u):$(id -g) /host/ffmpeg && chown $(id -u):$(id -g) /host/ffprobe && chown $(id -u):$(id -g) /host/ffplay"
docker rmi -f ffmpeg-compiler
