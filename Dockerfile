FROM nvcr.io/nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

ARG DEBIAN_FRONTEND="noninteractive"
ARG WORKSPACE="/home/workspace"
ARG TAG=v2.55.1
ARG CUDA_ARCH="86"

RUN apt-get update \
  && apt-get install -y \
  build-essential \
  cmake \
  clang \
  clang-tools \
  gdb \
  git \
  nano \
  libssl-dev \
  libusb-1.0-0-dev \
  libudev-dev \
  pkg-config \
  libgtk-3-dev \
  libglfw3-dev \
  libgl1-mesa-dev \
  libglu1-mesa-dev \
  v4l-utils \
  wget \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean 

WORKDIR /tmp 

RUN git clone --depth 1 -b ${TAG} https://github.com/IntelRealSense/librealsense.git \
  && cd librealsense \
  && mkdir build && cd build \
  && cmake \
  -D BUILD_WITH_CUDA=ON \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_CUDA_ARCHITECTURES=${CUDA_ARCH} \
  .. \
  && make -j $(nproc/2)\
  && make install

WORKDIR ${WORKSPACE}

COPY . .
