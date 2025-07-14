FROM quay.io/jupyter/pytorch-notebook:cuda12-notebook-7.4.4
LABEL maintainer="gianni.dallatorre@egi.eu"
LABEL description="Jupyter PyTorch image with SM 7.0 (Tesla V100) support"

USER root

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake build-essential libjpeg-dev libpng-dev \
    python3-dev curl libopenblas-dev libomp-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Switch to non-root user
USER jovyan

# Set environment variables
ENV TORCH_CUDA_ARCH_LIST="7.0" \
    MAX_JOBS=4 \
    PYTORCH_BUILD_VERSION=2.3.0 \
    PYTORCH_BUILD_NUMBER=1

# Clone and prepare PyTorch
RUN git clone https://github.com/pytorch/pytorch /tmp/pytorch && \
    cd /tmp/pytorch && \
    git checkout v${PYTORCH_BUILD_VERSION} && \
    git submodule update --init --recursive

# Build and install PyTorch
RUN cd /tmp/pytorch && \
    pip install -r requirements.txt && \
    python setup.py install && \
    cd /home/jovyan && rm -rf /tmp/pytorch

# Reinstall or upgrade PyTorch explicitly with CUDA 12.1 support
RUN pip install ---no-cache-dir -upgrade torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
