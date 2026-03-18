FROM python:3.11-slim

# Install notebook (Binder-compatible stack)
RUN pip install --no-cache-dir notebook

# Create the expected working directory
RUN mkdir -p /home/jovyan
WORKDIR /home/jovyan

# IMPORTANT: do NOT set CMD
