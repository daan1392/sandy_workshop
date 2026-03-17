############################################
# Stage 1 — Build NJOY + OpenMC
############################################
FROM python:3.11-slim AS builder

# Install build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    gfortran \
    cmake \
    git \
    curl \
    libhdf5-dev \
    hdf5-tools \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# --- Build NJOY2016 ---
RUN git clone --depth 1 https://github.com/njoy/NJOY2016.git \
 && cd NJOY2016 \
 && mkdir build && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release .. \
 && make -j$(nproc)

# --- Build OpenMC ---
RUN git clone --depth 1 https://github.com/openmc-dev/openmc.git \
 && cd openmc \
 && mkdir build && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release \
          -DOPENMC_ENABLE_MPI=OFF \
          -DOPENMC_USE_OPENMP=ON \
          -DOPENMC_USE_DEFAULT_PATHS=ON \
          .. \
 && make -j$(nproc)

# Install OpenMC Python API in builder stage
RUN cd openmc && pip install .

############################################
# Stage 2 — Runtime Dev Container Image
############################################
FROM mcr.microsoft.com/devcontainers/base:bookworm

# Environment variables
ARG NB_USER=vscode
ARG NB_UID=1000
ENV USER=${NB_USER} \
    HOME=/home/${NB_USER} \
    VIRTUAL_ENV=/opt/venv \
    PATH="$VIRTUAL_ENV/bin:$PATH" \
    NJOY=/usr/local/bin/njoy \
    LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}

# Install runtime and Python dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-venv \
    git \
    cmake \
    gfortran \
    g++ \
    libhdf5-dev \
    libhdf5-serial-dev \
    mpich \
    wget \
    ca-certificates \
    libgomp1 \
    libquadmath0 \
    libstdc++6 \
    hdf5-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create Python virtual environment
RUN python3 -m venv $VIRTUAL_ENV \
 && pip install --no-cache-dir --upgrade pip setuptools wheel \
 && pip install --no-cache-dir ipykernel jupyterlab \
 && pip install --no-cache-dir numpy scipy matplotlib pandas lxml h5py \
 && pip install --no-cache-dir sandy serpentTools seaborn scikit-learn

# Copy OpenMC binaries + libraries from builder
COPY --from=builder /openmc/build/bin/openmc /usr/local/bin/openmc
COPY --from=builder /openmc/build/lib /usr/local/lib
COPY --from=builder /openmc /usr/local/lib/python3.11/site-packages/openmc
COPY --from=builder /NJOY2016/build/njoy /usr/local/bin/njoy
COPY --from=builder /NJOY2016/build/libnjoy.so /usr/local/lib/

# Register OpenMC kernel for Jupyter
RUN python3 -m ipykernel install --name "openmc" --display-name "Python (OpenMC)"

# Prepare workspace
WORKDIR ${HOME}
COPY --chown=${NB_UID}:${NB_UID} Datalabs/ ${HOME}/Datalabs/
COPY --chown=${NB_UID}:${NB_UID} Extra/ ${HOME}/Extra/
COPY --chown=${NB_UID}:${NB_UID} data/ ${HOME}/data/

# Ensure permissions
RUN chown -R ${NB_UID}:${NB_UID} /opt/venv ${HOME}

# Switch to non-root user
USER ${NB_USER}

# Expose Jupyter port
ENV PORT=8888
EXPOSE 8888

# Default command for VS Code devcontainer / Codespaces
CMD ["jupyter", "lab", "--notebook-dir=/home/vscode/", "--port=8888", "--no-browser", "--ip=0.0.0.0"]
