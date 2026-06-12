FROM ubuntu:26.04 AS runtime

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install essential packages
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update && apt-get install -y \
    wget \
    gpg \
    ca-certificates \
    python3 \
    python3-pip

# Setup ROCm repository
RUN mkdir --parents --mode=0755 /etc/apt/keyrings && \
    wget https://repo.amd.com/rocm/packages/gpg/rocm.gpg -O - | \
    gpg --dearmor | tee /etc/apt/keyrings/amdrocm.gpg > /dev/null && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/amdrocm.gpg] https://repo.amd.com/rocm/packages-multi-arch/ubuntu2604 stable main" > /etc/apt/sources.list.d/rocm.list

# Install ROCm 7.13.0 for Ubuntu 24.04
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
    && apt-get install -y amdrocm7.13-gfx1151

# Cache busting argument to force apt update
ARG APT_CACHEBUST=1

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
    && apt-get upgrade --no-install-recommends -y


# Set environment variables for ROCm/Unsloth
ENV ROCM_PATH=/opt/rocm
ENV PATH="${ROCM_PATH}/bin:${PATH}"

# Placeholder for Unsloth installation
# RUN pip install unsloth

WORKDIR /app

CMD ["bash"]
