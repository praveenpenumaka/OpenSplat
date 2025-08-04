#!/bin/bash

TORCH_VERSIONS=$(curl -s https://pypi.org/pypi/torch/json | jq -r '.releases | keys[]' | sort -Vr )

# Split TORCH_VERSIONS into an array
TORCH_VERSIONS=($TORCH_VERSIONS)

# Cuda_versions should be like cu118, cu121, cu128
CUDA_VERSIONS=$(curl -s https://developer.nvidia.com/cuda-toolkit-archive | \
  grep -oE 'CUDA Toolkit ([0-9]+\.[0-9]+(\.[0-9]+)?)' | \
  sed -E 's/.*CUDA Toolkit ([0-9]+\.[0-9]+(\.[0-9]+)?).*/\1/' | \
  # Filter out versions that are too old (before 10.0) and convert to cu format
  grep -E '^[1-9][0-9]+\.[0-9]+' | \
  sed -E 's/([0-9]+)\.([0-9]+)(\.[0-9]+)?/\1\2/' | \
  sed 's/^/cu/' | sort -Vr | uniq)

# Split CUDA_VERSIONS into an array
CUDA_VERSIONS=($CUDA_VERSIONS)

for torch_version in "${TORCH_VERSIONS[@]}"; do
  for cuda_id in "${CUDA_VERSIONS[@]}"; do
    url="https://download.pytorch.org/libtorch/${cuda_id}/libtorch-cxx11-abi-shared-with-deps-${torch_version}%2B${cuda_id}.zip"
    if curl --silent --head --fail "$url" > /dev/null; then
      echo "✅ Found: $torch_version with $cuda_id"
    fi
  done
done