FROM ubuntu:26.04 AS runtime

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install essential packages
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt update && apt install -y \
    wget \
    gpg \
    ca-certificates \
    python3 \
    python3-pip \
    && useradd -m -s /bin/bash unsloth

# Setup ROCm repository
RUN mkdir --parents --mode=0755 /etc/apt/keyrings && \
    wget https://repo.amd.com/rocm/packages/gpg/rocm.gpg -O - | \
    gpg --dearmor | tee /etc/apt/keyrings/amdrocm.gpg > /dev/null && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/amdrocm.gpg] https://repo.amd.com/rocm/packages-multi-arch/ubuntu2604 stable main" \
        > /etc/apt/sources.list.d/rocm.list

# Install ROCm 7.13.0 for Ubuntu 26.04
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt clean all \
    && apt update \
    && apt install -y \
        amdrocm7.13-gfx1151 \
        amdrocm-core-sdk7.13-gfx1151

# Cache busting argument to force apt update
ARG APT_CACHEBUST=1

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt update \
    && apt upgrade --no-install-recommends -y

ENV XDG_CACHE_HOME=/pip
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Install torch
RUN \
    --mount=target=/apt,type=cache,sharing=locked \
    python3 -m pip install --prefer-binary --upgrade \
        --index-url https://repo.amd.com/rocm/whl/gfx1151/ \
        "rocm[libraries,devel]" \
        torch \
        torchvision \
        torchaudio
RUN \
    --mount=target=/apt,type=cache,sharing=locked \
    python3 -m pip install --prefer-binary --upgrade \
        --extra-index-url https://repo.amd.com/rocm/whl/gfx1151/ \
        "jax_rocm7_plugin==0.9.1+rocm7.13.0" \
        "jax_rocm7_pjrt==0.9.1+rocm7.13.0" \
        "triton==3.6.0+rocm7.13.0" \
        tf-keras
RUN \
    --mount=target=/apt,type=cache,sharing=locked \
    python3 -m pip install --prefer-binary --upgrade \
        "jax==0.9.1" \
        "jaxlib==0.9.1"
RUN \
    --mount=target=/apt,type=cache,sharing=locked \
    python3 -m pip install --prefer-binary --upgrade \
        https://rocm.frameworks.amd.com/whl/gfx1151/flash_attn-2.8.3-py3-none-any.whl

# Install extra Unsloth dependencies
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt update && apt install -y \
    cmake git libcurl4-openssl-dev flang
ENV PATH=/opt/rocm/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/rocm/lib/
ENV CMAKE_PREFIX_PATH="/opt/rocm/lib/host-math/lib/cmake/"
ENV PKG_CONFIG_PATH="/opt/rocm/lib/host-math/lib/pkgconfig"
RUN \
    --mount=target=/apt,type=cache,sharing=locked \
    python3 -m pip install --prefer-binary --upgrade \
        scikit-learn==1.7.1

# Install Unsloth
RUN \
    --mount=target=/apt,type=cache,sharing=locked \
    wget https://unsloth.ai/install.sh -O -| \
        UNSLOTH_NO_TORCH=1 \
        UNSLOTH_PYTHON=3.14 \
        UNSLOTH_STUDIO_HOME=/unsloth \
        UNSLOTH_PYTORCH_MIRROR=https://repo.amd.com/rocm/whl/gfx1151/ \
        UNSLOTH_AMD_ROCM_MIRROR=https://repo.amd.com/rocm/whl/gfx1151/ \
        UNSLOTH_LLAMA_CPP_PATH=/llama.cpp \
        UNSLOTH_ROCM_GFX_ARCH=gfx1151 \
        sh

# Set environment variables for ROCm/Unsloth
ENV ROCM_PATH=/opt/rocm
ENV PATH="${ROCM_PATH}/bin:${PATH}"

# Volumes for Unsloth/HuggingFace data
VOLUME ["/home/unsloth/.unsloth"]

# copy/install as root, so the "unsloth" user can't change anything, only in /home/unsloth
WORKDIR /app
COPY unsloth.sh /app
RUN chmod +x /app/unsloth.sh

USER unsloth

ENTRYPOINT ["/app/unsloth.sh"]
CMD ["unsloth", "studio"]

