# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-ubuntu:noble

# set version label
ARG BUILD_DATE
ARG VERSION
ARG FOLDINGATHOME_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

#Add needed nvidia environment variables for container toolkit
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

# global environment settings
ENV DEBIAN_FRONTEND="noninteractive"

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y \
    intel-opencl-icd && \
  ln -s libOpenCL.so.1 /usr/lib/x86_64-linux-gnu/libOpenCL.so && \
  echo "**** install foldingathome ****" && \
  download_url=$(curl -H 'Accept-Encoding: gzip' -fSsL --compressed https://download.foldingathome.org/releases.py | jq -r '.[] | select(.title=="64bit Linux") | .groups[].files[].url' | grep "fah-client" | grep "amd64.deb") && \
  curl -o \
    /tmp/fah.deb -L \
    ${download_url} && \
  dpkg -x /tmp/fah.deb / && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /var/log/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 7396

VOLUME /config
