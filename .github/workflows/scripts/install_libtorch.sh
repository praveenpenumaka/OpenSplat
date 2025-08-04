CUDA_VERSION=$1
TORCH_VERSION=$2

get_cuda_id() {
    local cuda_version=$1
    local cuda_id=0
    # Remove the last digit from the cuda_version
    cuda_version=${cuda_version%?}
    # Remove the . from the cuda_version
    cuda_version=${cuda_version//./}
    # Add the cu prefix
    CUDA_ID="cu$cuda_version"
    echo $CUDA_ID
}

get_torch_url() {
    cuda_version=$1
    torch_version=$2
    cuda_id=$(get_cuda_id $cuda_version)
    torch_url="https://download.pytorch.org/libtorch/${cuda_id}/libtorch-cxx11-abi-shared-with-deps-${torch_version}%2B${cuda_id}.zip"
    echo $torch_url
}

TORCH_URL=$(get_torch_url $CUDA_VERSION $TORCH_VERSION)
wget -q "$TORCH_URL" -O libtorch.zip
unzip libtorch.zip -d /opt
rm libtorch.zip
