# Args
ARG IMAGE_VERSION="ubuntu:20.04"

FROM ghcr.io/mit-dci/opencbdc-tx-base AS builder

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

# Deployment Image
FROM $IMAGE_VERSION AS deploy

WORKDIR /opt/tx-processor

# Copy All of the ./build directory
# COPY --from=builder  /opt/tx-processor/build ./build

# Only copy essential binaries
COPY --from=builder  /opt/tx-processor/build/src/uhs/twophase/sentinel_2pc/sentineld-2pc ./build/src/uhs/twophase/sentinel_2pc/sentineld-2pc
COPY --from=builder  /opt/tx-processor/build/src/uhs/twophase/coordinator/coordinatord ./build/src/uhs/twophase/coordinator/coordinatord
COPY --from=builder  /opt/tx-processor/build/src/uhs/twophase/locking_shard/locking-shardd ./build/src/uhs/twophase/locking_shard/locking-shardd

# Copy Client CLI
COPY --from=builder  /opt/tx-processor/build/src/uhs/client/client-cli ./build/src/uhs/client/client-cli

# Copy config
COPY --from=builder  /opt/tx-processor/2pc-compose.cfg ./2pc-compose.cfg
COPY --from=builder  /opt/tx-processor/atomizer-compose.cfg ./atomizer-compose.cfg
