#!/bin/bash
set -e

echo "Building..."

if [ -z ${BUILD_DIR+x} ]; then
    export BUILD_DIR=build
fi

mkdir -p $BUILD_DIR
cd $BUILD_DIR


CPUS=1
CMAKE_FLAGS=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CPUS=$(grep -c ^processor /proc/cpuinfo)
elif [[ "$OSTYPE" == "darwin"* ]]; then
    CPUS=$(sysctl -n hw.ncpu)
    XCODE_CMDLINE_DIR=$(xcode-select -p)
    CMAKE_FLAGS+="-DCMAKE_MAKE_PROGRAM=/usr/local/bin/gmake -DCMAKE_C_COMPILER=${XCODE_CMDLINE_DIR}/usr/bin/clang -DCMAKE_CXX_COMPILER=${XCODE_CMDLINE_DIR}/usr/bin/clang++ -DCMAKE_CXX_FLAGS=-isystem\ /usr/local/include -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
fi

CMAKE_BUILD_TYPE="Debug"
if [[ "$BUILD_RELEASE" == "1" ]]; then
    CMAKE_BUILD_TYPE="Release"
elif [[ "$BUILD_PROFILING" == "1" ]]; then
    CMAKE_BUILD_TYPE="Profiling"
fi

eval "cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} ${CMAKE_FLAGS} .."
make -j$CPUS
