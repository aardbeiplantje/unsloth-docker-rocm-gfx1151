#!/bin/bash
DOCKER_IMAGE=${DOCKER_IMAGE:-local/ai/unsloth-gfx1151:latest}
UNSLOTH_DATA=${UNSLOTH_DATA:-~/.unsloth/studio}
if [ ! -d "$UNSLOTH_DATA" ]; then
    mkdir -p "$UNSLOTH_DATA"
fi
UNSLOTH_DATA=$(readlink -f "$UNSLOTH_DATA")
OPTS=""
if [ -z "$*" ]; then
    OPTS="--restart=unless-stopped --detach"
else
    OPTS="-it --rm"
fi
# debug:
OPTS="-it --rm"
ROCM_PATH=${ROCM_PATH:-/opt/rocm}
docker stop unsloth >/dev/null 2>&1 || true
docker rm unsloth >/dev/null 2>&1 || true
exec docker run \
    $OPTS \
    --network=host \
    --ulimit memlock=-1:-1 \
    --ulimit stack=67108864:67108864 \
    --group-add=video \
    --ipc=host \
    --shm-size=4g \
    --cap-add=SYS_PTRACE \
    --security-opt seccomp=unconfined \
    --group-add 986 \
    --group-add 109 \
    --group-add 992 \
    --device /dev/kfd \
    --device /dev/dri \
    -v $UNSLOTH_DATA:/unsloth/studio \
    -v $HF_HOME:$HF_HOME \
    -v $HF_HUB_CACHE:$HF_HUB_CACHE \
    -v $ROCM_PATH:/opt/rocm \
    -e HF_HOME \
    -e HF_TOKEN \
    -e HF_HUB_CACHE \
    -e UNSLOTH_DATA \
    -e CUDA_VISIBLE_DEVICES="" \
    -e TF_ENABLE_ONEDNN_OPTS=0 \
    -e TF_XLA_FLAGS_DISABLED=1 \
    -e ROCM_PATH=/opt/rocm \
    $DOCKER_IMAGE \
        "$@"
