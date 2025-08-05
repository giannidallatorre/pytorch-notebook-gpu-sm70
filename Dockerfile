# Stage 1: Build Julia environment and install packages
FROM julia:1.10 AS julia_build

# Install IJulia and CUDA.jl
ENV JULIA_DEPOT_PATH=/opt/julia_depot
RUN mkdir -p $JULIA_DEPOT_PATH

RUN julia -e 'using Pkg; Pkg.add("IJulia"); Pkg.add("CUDA"); Pkg.gc();'


# Stage 2: Final image with Python, PyTorch, and the Julia environment from Stage 1
# Use an official NVIDIA CUDA base image with dev tools and Ubuntu 22.04
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

LABEL maintainer="gianni.dallatorre@egi.eu"
LABEL description="Jupyter + PyTorch (CUDA 12.1) + Julia for Tesla V100 (sm70)"

# Install Python, pip, and optionally virtualenv support
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 python3.10-venv python3-pip git \
    && rm -rf /var/lib/apt/lists/*

# Make python3.10 the default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
 && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install JupyterHub (singleuser), JupyterLab, and notebook server
# Install PyTorch + CUDA 12.1 from PyTorch official index
RUN pip install --no-cache-dir \
    jupyterlab notebook jupyterhub \
 && pip install --no-cache-dir \
    torch==2.3.0 torchvision==0.18.0 torchaudio==2.3.0 \
    --index-url https://download.pytorch.org/whl/cu121 \
 && pip cache purge

# Copy Julia Installation from the build stage
COPY --from=julia_build /usr/local/julia /usr/local/julia
COPY --from=julia_build /opt/julia_depot /opt/julia_depot

# Create a non-root user
RUN groupadd -g 1000 jovyan && \
    useradd -m -s /bin/bash -u 1000 -g jovyan jovyan && \
    chown -R jovyan:jovyan /opt/julia_depot
USER jovyan
WORKDIR /home/jovyan
ENV PATH="/usr/local/julia/bin:/home/jovyan/.local/bin:${PATH}"
ENV JULIA_DEPOT_PATH=/opt/julia_depot

#RUN julia -e 'using Pkg; Pkg.activate("."); Pkg.add("IJulia"); Pkg.add("CUDA");'
RUN julia -e 'using Pkg; Pkg.add("IJulia"); Pkg.add("CUDA");'
RUN echo "🔥 Built at $(date -u) in CI run $CI" > /home/jovyan/build-marker.txt

# Expose Jupyter port
EXPOSE 8888

# Launch JupyterLab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--ServerApp.token=''"]

