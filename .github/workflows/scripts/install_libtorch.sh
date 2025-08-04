CUDA_VERSION=$1
TORCH_VERSION=$2

get_cuda_id() {
    # Remove the last digit from the cuda_version
    CUDA_SMALLER_VERSION=$(echo $CUDA_VERSION | cut -d'.' -f1-2)
    # Remove the . from the cuda_version
    CUDA_SMALLER_VERSION=$(echo $CUDA_SMALLER_VERSION | sed 's/\.//g')
    # Add the cu prefix
    CUDA_ID="cu$CUDA_SMALLER_VERSION"
}

get_torch_url() {
    get_cuda_id
    TORCH_URL="https://download.pytorch.org/libtorch/${CUDA_ID}/libtorch-cxx11-abi-shared-with-deps-${TORCH_VERSION}%2B${CUDA_ID}.zip"
}

get_torch_url $CUDA_VERSION $TORCH_VERSION
echo $TORCH_URL
wget -q "$TORCH_URL" -O libtorch.zip
# unzip libtorch.zip -d /opt
# rm libtorch.zip
