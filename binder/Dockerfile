FROM python:3.11-slim

# Install required system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        libnss3 \
        fonts-dejavu \
    && rm -rf /var/lib/apt/lists/*

# Install JupyterLab (stable Binder default)
RUN pip install --no-cache-dir jupyterlab

# Binder expects this directory
WORKDIR /home/jovyan

# Start Jupyter
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--no-browser", "--port=8888", "--allow-root"]
