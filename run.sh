#!/bin/bash
DOCKER_IMAGE=${DOCKER_IMAGE:-local/ai/unsloth-gfx1151:latest}
UNSLOTH_DATA=${UNSLOTH_DATA:-~/.unsloth}
UNSLOTH_DATA=$(readlink -f "$UNSLOTH_DATA")
OPTS=""
if [ x"$@" = x"" ]; then
    set -- \
        studio \
        --port 8888 \
        --host [::] \
        "$@"
    OPTS="--restart=unless-stopped --detach"
else
    OPTS="-it --rm"
fi
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
    --group-add 109 \
    --group-add 992 \
    --device /dev/kfd \
    --device /dev/dri \
    -v $UNSLOTH_DATA:$UNSLOTH_DATA \
    -v $HF_HOME:$HF_HOME \
    -v $HF_HUB_CACHE:$HF_HUB_CACHE \
    -e HF_HOME \
    -e HF_TOKEN \
    -e HF_HUB_CACHE \
    -e UNSLOTH_DATA \
    $DOCKER_IMAGE \
        "$@"
