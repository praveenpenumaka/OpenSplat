
ARG CUDA_VERSION=12.8.1
ARG UBUNTU_VERSION=22.04
ARG TORCH_VERSION=2.7.1
ARG CMAKE_BUILD_TYPE=Release
ARG CMAKE_CUDA_ARCHITECTURES="70;75;80;86;87;89;90;100;101;120"

FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION}

ARG CUDA_VERSION
ARG CUDA_ID
ARG UBUNTU_VERSION
ARG TORCH_VERSION
ARG CMAKE_BUILD_TYPE
ARG CMAKE_CUDA_ARCHITECTURES

SHELL ["/bin/bash", "-c"]

# Env variables
ENV DEBIAN_FRONTEND noninteractive

# Prepare directories
WORKDIR /code

# Copy everything
COPY . ./

RUN chmod +x .github/workflows/scripts/*

# Upgrade cmake if Ubuntu version is 20.04
RUN sh .github/workflows/scripts/upgrade_cmake.sh ${UBUNTU_VERSION}

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    git \
    ninja-build \
    libopencv-dev \
    unzip \
    wget \
    sudo && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install LibTorch
RUN sh .github/workflows/scripts/install_libtorch.sh ${CUDA_VERSION} ${TORCH_VERSION}

# Configure and build \
RUN source .github/workflows/scripts/set_cuda_paths.sh ${CUDA_VERSION} && \
    mkdir build && \
    cd build && \
    cmake .. \
    -GNinja \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DCMAKE_PREFIX_PATH=/opt/libtorch \
    -DCMAKE_INSTALL_PREFIX=/code/install \
    -DCMAKE_CUDA_ARCHITECTURES="${CMAKE_CUDA_ARCHITECTURES}" \
    -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_HOME} && \
    ninja
