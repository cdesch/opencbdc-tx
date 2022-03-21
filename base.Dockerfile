ARG IMAGE_VERSION="ubuntu:20.04"

FROM $IMAGE_VERSION AS base

ARG CMAKE_BUILD_TYPE="Release"
ARG LEVELDB_VERSION="1.22"
ARG NURAFT_VERSION="1.3.0"

# Set working directory
WORKDIR /opt/tx-processor

# set non-interactive shell
ENV DEBIAN_FRONTEND noninteractive

# install base packages
RUN apt update && \
    apt install -y \
    build-essential \
    wget \
    cmake \
    libgtest-dev \
    libgmock-dev \
    net-tools \
    lcov \
    git

# Install LevelDB
RUN wget https://github.com/google/leveldb/archive/${LEVELDB_VERSION}.tar.gz && \
    tar xzvf ${LEVELDB_VERSION}.tar.gz && \
    rm -f ${LEVELDB_VERSION}.tar.gz && \
    cd leveldb-${LEVELDB_VERSION} && \
    cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DLEVELDB_BUILD_TESTS=0 -DLEVELDB_BUILD_BENCHMARKS=0 -DBUILD_SHARED_LIBS=0 . && \
    make -j$(nproc) && \
    make install

# Install NuRaft
RUN wget https://github.com/eBay/NuRaft/archive/v${NURAFT_VERSION}.tar.gz && \
    tar xzvf v${NURAFT_VERSION}.tar.gz && \
    rm v${NURAFT_VERSION}.tar.gz && \
    cd "NuRaft-${NURAFT_VERSION}" && \
    ./prepare.sh && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DDISABLE_SSL=1 .. && \
    make -j$(nproc) static_lib && \
    cp libnuraft.a /usr/local/lib && \
    cp -r ../include/libnuraft /usr/local/include
