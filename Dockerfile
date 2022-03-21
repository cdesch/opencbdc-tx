
ARG CMAKE_BUILD_TYPE="Release"
ARG IMAGE_VERSION="ubuntu:20.04"

FROM ghcr.io/mit-dci/opencbdc-tx-base AS builder

# Copy source
COPY . .

# Update submodules and run configure.sh
RUN git submodule init && git submodule update

# Build binaries
RUN mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} .. && \
    make -j$(nproc)

# Deployment Image
FROM $IMAGE_VERSION AS deploy

WORKDIR /opt/tx-processor

# Copy files
COPY --from=builder  /opt/tx-processor .
