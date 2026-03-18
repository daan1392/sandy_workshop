FROM python:3.11-slim

# Install only Jupyter
RUN pip install --no-cache-dir notebook

# Set working directory
WORKDIR /home/jovyan

# Start notebook server
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]