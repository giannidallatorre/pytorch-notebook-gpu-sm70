# Use an official NVIDIA CUDA base image.
# This version includes CUDA 12.1.1, cuDNN 8, and the development tools.
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

LABEL maintainer="gianni.dallatorre@egi.eu"
LABEL description="Optimized Jupyter PyTorch image with CUDA 12.1 support for Tesla V100 (SM 7.0)"

# Install Python, pip, and other essentials in a single layer to save space
# Clean up apt-get cache in the same RUN command
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user 'jovyan' and set it as the working directory
# This mimics the environment of the original jupyter images
RUN useradd -m -s /bin/bash -N -u 1000 jovyan
USER jovyan
WORKDIR /home/jovyan

# Add the user's local bin AND the NVIDIA tools directory to the PATH.
# This ensures that executables installed by pip (like jupyter) are found.
ENV PATH="/home/jovyan/.local/bin:/usr/local/nvidia/bin:${PATH}"

# Install Jupyter, PyTorch, and related libraries using pip, downloads the pre-compiled binaries
# Use --no-cache-dir reduces the final image size
# Use --extra-index-url to add the PyTorch repo instead of replacing the default one.
RUN pip install --no-cache-dir jupyterlab \
    torch==2.3.0 torchvision==0.18.0 torchaudio==2.3.0 --extra-index-url https://download.pytorch.org/whl/cu121

# Expose the default Jupyter port
EXPOSE 8888

# Set the default command to start JupyterLab
# It will be accessible on all network interfaces inside the container
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--ServerApp.token=''"]
