# ===== Stage 1: Build NJOY =====
FROM python:3.12-slim AS njoy-builder

# Build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gfortran build-essential cmake git wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Clone and build NJOY2016
RUN git clone --depth 1 https://github.com/njoy/NJOY2016.git \
 && cd NJOY2016 \
 && mkdir build && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release .. \
 && make -j$(nproc)

# ===== Stage 2: Binder environment =====
FROM python:3.12-slim

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip python3-venv libhdf5-dev libopenblas-dev mpich wget ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Minimal Python + Jupyter
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel \
 && /opt/venv/bin/pip install --no-cache-dir jupyterlab ipykernel

# Copy NJOY binary and library
COPY --from=njoy-builder /NJOY2016/build/njoy /usr/local/bin/njoy
COPY --from=njoy-builder /NJOY2016/build/libnjoy.so /usr/local/lib/
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/njoy.conf && ldconfig
ENV NJOY=/usr/local/bin/njoy

# Set PATH to use virtualenv Python
ENV PATH="/opt/venv/bin:$PATH"

# Workspace
WORKDIR /home/jovyan

# Expose Jupyter port
EXPOSE 8888

# Launch Jupyter (minimal)
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--no-browser", "--allow-root"]
