FROM ghcr.io/mit-dci/opencbdc-tx-base AS builder

# Args
ARG CMAKE_BUILD_TYPE="Release"

# Copy source
COPY . .

# Update submodules and run configure.sh
RUN git submodule init && git submodule update

# Build binaries
RUN mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} .. && \
    make -j$(nproc)
