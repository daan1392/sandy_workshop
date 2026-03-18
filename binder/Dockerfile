# ===== Stage 1: NJOY builder =====
FROM python:3.12-slim AS njoy-builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gfortran \
    cmake \
    git \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Clone and build NJOY2016
RUN git clone --depth 1 https://github.com/njoy/NJOY2016.git \
 && cd NJOY2016 \
 && mkdir build && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release .. \
 && make -j$(nproc)

# ===== Stage 2: Binder environment =====
FROM python:3.12-slim AS binder-env

# System packages for Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-venv python3-pip wget ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create virtualenv
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel \
 && /opt/venv/bin/pip install --no-cache-dir \
    ipykernel jupyterlab numpy scipy matplotlib pandas seaborn sandy

# Copy NJOY executable from builder
COPY --from=njoy-builder /NJOY2016/build/NJOY* /usr/local/bin/

# Install Jupyter kernel
RUN /opt/venv/bin/python -m ipykernel install --name "sandy" --display-name "Python (Sandy)"

# Set working directory
WORKDIR /home/jovyan

# Expose Jupyter port
EXPOSE 8888

# Start Jupyter Lab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--no-browser", "--allow-root"]
