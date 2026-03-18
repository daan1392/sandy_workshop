FROM python:3.11-slim

# Install classic notebook (NOT notebook 7 / lab 4 stack)
RUN pip install --no-cache-dir "notebook<7"

WORKDIR /home/jovyan

CMD ["jupyter", "notebook", \
     "--ip=0.0.0.0", \
     "--port=8888", \
     "--no-browser", \
     "--allow-root", \
     "--NotebookApp.token=''", \
     "--NotebookApp.password=''"]
