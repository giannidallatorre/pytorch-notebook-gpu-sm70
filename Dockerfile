FROM quay.io/jupyter/pytorch-notebook:cuda12-notebook-7.4.4

LABEL maintainer="gianni.dallatorre@egi.eu"
LABEL description="Jupyter PyTorch image with SM 7.0 (Tesla V100) support"

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    libjpeg-dev libpng-dev libopenblas-dev libomp-dev \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

USER jovyan

# Install precompiled PyTorch with CUDA 12.1 (compatible with SM 7.0)
RUN pip install --no-cache-dir --upgrade torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
