# 🚀 Docker Image: Jupyter notebooks + Julia + Python + CUDA (V100-Optimized) 

This Docker image comes with:

- **Jupyter notebooks**
- **Julia**
- **Python** (with **Jupyter notebooks**)
- **NVIDIA CUDA Toolkit**

It is specifically built and optimized to run on systems equipped with **NVIDIA Tesla V100 GPUs**.

> 🎯 **Why V100?**  
The image targets the **CUDA 11.8** architecture (compute capability 7.0 / `V100` hardware).

It's built for systems with **NVIDIA GPUs** (e.g., A100, V100), and enables **GPU-accelerated** development for machine learning, scientific computing, and numerical workloads.

> ✅ Requires [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) (`nvidia-docker`) and a compatible GPU driver on the host.

---

## 🔧 Build the Image Locally

```bash
docker build -t pytorch-notebook-gpu-sm70 .
```

---

## ▶️ Run the Container with GPU Support

Make sure `nvidia-docker` is installed and run:

```bash
docker run --gpus all -it pytorch-notebook-gpu-sm70
```

To expose Jupyter notebooks:

```bash
docker run --gpus all -p 8888:8888 -it pytorch-notebook-gpu-sm70
```

Then open `http://localhost:8888` in your browser.

---

## ⚙️ GitHub Actions CI

This repo includes a GitHub Actions workflow that:

- Builds the Docker image on every push or PR
- Can optionally push the image to Docker Hub or GHCR

> To enable publishing, configure the following repository secrets:

- `DOCKER_USERNAME`
- `DOCKER_PASSWORD` or `DOCKER_TOKEN`

---

## 📄 License

MIT
