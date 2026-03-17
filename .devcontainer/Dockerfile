############################################
# Stage 1 — Build NJOY
############################################
FROM python:3.12-slim AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    gfortran \
    cmake \
    git \
    libhdf5-dev \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# --- Build NJOY2016 ---
RUN git clone --depth 1 https://github.com/njoy/NJOY2016.git \
 && cd NJOY2016 \
 && mkdir build && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release .. \
 && make -j$(nproc)



############################################
# Stage 2 — Devcontainer runtime
############################################
FROM mcr.microsoft.com/devcontainers/python:3.12 AS dev_containers_target_stage

ARG NB_USER=vscode
ARG NB_UID=1000

ENV USER=${NB_USER} \
    HOME=/home/${NB_USER} \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gfortran \
    g++ \
    cmake \
    git \
    libhdf5-dev \
    libhdf5-serial-dev \
    hdf5-tools \
    libatlas-base-dev \
    liblapack-dev \
    libopenblas-dev \
    mpich \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

############################################
# Python environment
############################################
RUN python3 -m venv $VIRTUAL_ENV \
 && $VIRTUAL_ENV/bin/pip install --upgrade pip setuptools wheel

# Scientific stack
RUN $VIRTUAL_ENV/bin/pip install \
    numpy scipy matplotlib pandas lxml h5py \
    seaborn scikit-learn

# Nuclear tools
RUN $VIRTUAL_ENV/bin/pip install \
    openmc \
    sandy \
    serpentTools

# Jupyter
RUN $VIRTUAL_ENV/bin/pip install \
    ipykernel jupyterlab \
 && $VIRTUAL_ENV/bin/python -m ipykernel install \
    --name "sandy" \
    --display-name "Python (Sandy)"

############################################
# Copy NJOY from builder
############################################
COPY --from=builder /NJOY2016/build/njoy /usr/local/bin/njoy

############################################
# Final setup
############################################
RUN ldconfig

WORKDIR ${HOME}
RUN chown -R ${NB_UID}:${NB_UID} /opt/venv ${HOME}

USER ${NB_USER}

############################################
# Jupyter
############################################
ENV PORT=8888
EXPOSE 8888

CMD ["jupyter", "lab", "--notebook-dir=/home/vscode/", "--port=8888", "--no-browser", "--ip=0.0.0.0"]
