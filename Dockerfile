FROM python:3.9-slim-bullseye

# Install dummy affinity library
RUN apt-get update && \
    apt-get install -y gcc && \
    echo "int pthread_setaffinity_np(void) { return 0; }" > dummy_affinity.c && \
    gcc -shared -o /usr/lib/dummy_affinity.so dummy_affinity.c -fPIC && \
    apt-get remove -y gcc && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* dummy_affinity.c

# Set all possible thread control variables
ENV OMP_NUM_THREADS=1 \
    OMP_WAIT_POLICY=PASSIVE \
    KMP_AFFINITY=disabled \
    KMP_BLOCKTIME=0 \
    TF_NUM_INTEROP_THREADS=1 \
    TF_NUM_INTRAOP_THREADS=1 \
    ORT_DISABLE_THREAD_AFFINITY=1 \
    ORT_GLOBAL_DISABLE_AFFINITY=1 \
    ORT_LOG_LEVEL=3

# Install system dependencies
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    git \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and set up Python environment
RUN pip install --upgrade pip setuptools wheel

# Install Python packages with specific versions
RUN pip install --no-cache-dir numpy==1.23.5 Pillow==9.5.0 && \
    pip install --no-cache-dir opencv-python-headless==4.7.0.72 && \
    pip install --no-cache-dir onnxruntime==1.14.1 && \
    pip install --no-cache-dir pyclipper==1.3.0.post4 shapely==2.0.1 && \
    pip install --no-cache-dir ddddocr==1.5.6

# Copy bootstrap script
COPY bootstrap.sh /bootstrap.sh
RUN chmod +x /bootstrap.sh

# Clone repo and set up
RUN git clone https://github.com/whiteout-project/bot /app && \
    cd /app && \
    echo 0 > bot_token.txt

WORKDIR /app
ENTRYPOINT ["/bootstrap.sh"]
