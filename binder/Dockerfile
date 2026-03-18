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

# ===== Stage 2: Minimal Binder container =====
FROM python:3.12-slim

# System dependencies (runtime)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libhdf5-dev libopenblas-dev mpich wget ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ===== Copy NJOY binaries =====
COPY --from=njoy-builder /NJOY2016/build/njoy /usr/local/bin/njoy
COPY --from=njoy-builder /NJOY2016/build/libnjoy.so /usr/local/lib/
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/njoy.conf \
 && ldconfig
ENV NJOY=/usr/local/bin/njoy

# ===== Workspace =====
WORKDIR /home/jovyan

# ===== Jupyter =====
# Optional: keep Jupyter for Binder testing
# RUN python3 -m pip install --no-cache-dir jupyterlab ipykernel
EXPOSE 8888
CMD ["bash"]
