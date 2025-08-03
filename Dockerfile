
ARG CUDA_VERSION=12.8
ARG CUDA_ID=cu128
ARG UBUNTU_VERSION=22.04
ARG TORCH_VERSION=2.7.1

FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION}

ARG CUDA_VERSION
ARG CUDA_ID
ARG UBUNTU_VERSION
ARG TORCH_VERSION

SHELL ["/bin/bash", "-c"]

# Env variables
ENV DEBIAN_FRONTEND noninteractive

# Prepare directories
WORKDIR /code

# Copy everything
COPY . ./

# Upgrade cmake if Ubuntu version is 20.04
RUN if [[ "$UBUNTU_VERSION" = "20.04" ]]; then \
        apt-get update && \
        apt-get install -y ca-certificates gpg wget && \
        wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
        echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null && \
        apt-get update && \
        apt-get install kitware-archive-keyring && \
        echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal-rc main' | tee -a /etc/apt/sources.list.d/kitware.list >/dev/null; \
    fi

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
ARG TORCH_URL=https://download.pytorch.org/libtorch/${CUDA_ID}/libtorch-cxx11-abi-shared-with-deps-${TORCH_VERSION}%2B${CUDA_ID}.zip

RUN echo ${TORCH_URL} > /tmp/torch.txt
RUN cat /tmp/torch.txt
RUN wget -q "$TORCH_URL" -O libtorch.zip
RUN unzip libtorch.zip -d /opt
RUN rm libtorch.zip

#ENV Torch_DIR=/opt/libtorch/share/cmake/Torch
#ENV LD_LIBRARY_PATH=/opt/libtorch/lib:$LD_LIBRARY_PATH
#ENV PATH=/opt/libtorch/bin:$PATH


# Configure and build \
RUN source .github/workflows/cuda/Linux-env.sh cu"${CUDA_VERSION%%.*}"$(echo $CUDA_VERS#ION | cut -d'.' -f2) && \
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
