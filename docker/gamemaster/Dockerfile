# Use the specified Rust version and base OS as the base image
ARG BASE_OS
ARG RUST_VERSION
FROM rust:${RUST_VERSION}-${BASE_OS}

RUN apt update

# install some usefull tools/shortcuts

RUN apt install tree -y
RUN apt install curl -y
RUN apt install python3 python3-pip python3-venv -y

# install ML dependencies for EVA Qwen2.5-72B model
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
RUN pip3 install --no-cache-dir transformers safetensors accelerate

# create container user with same rights than host user

RUN groupadd -g 1000 appuser && \
    useradd -m -u 1000 -g 1000 -s /bin/bash appuser

# global configuration done ! let's focus on the project itself

WORKDIR /app
RUN chown -R appuser:appuser /app

USER appuser