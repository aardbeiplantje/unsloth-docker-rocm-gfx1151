#!/bin/bash

set -e

docker buildx use megabuilder >/dev/null 2>&1 || \
docker buildx create --use --name megabuilder \
  --driver docker-container \
  --driver-opt network=host \
  --platform linux/amd64,linux/arm64,linux/aarch64 \
  --buildkitd-flags '--allow-insecure-entitlement security.insecure'

docker buildx bake --allow=fs.read=$ROCM_PATH --allow=security.insecure --allow=device --progress=plain
