# Getting base image with platform specified (important if you build on Apple Silicon)
FROM --platform=linux/amd64 mambaorg/micromamba:2.5-cuda12.8.1-ubuntu24.04

USER root
# Installing ssh, rsync, rclone, anaconda, vscode-server
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y sudo rsync rclone zsh git curl wget vim tmux
RUN mkdir -p /opt/vscode-cli
RUN wget -q -O- "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64" | gunzip | tar xvf - -C /opt/vscode-cli 


# Configuring Anaconda

WORKDIR /tmp
ENV MAMBA_ROOT_PREFIX=/opt/conda
ENV MAMBA_DISABLE_LOCKFILE=TRUE
ENV PIP_EXTRA_INDEX_URL="https://download.pytorch.org/whl/cu128"
ENV PIP_FIND_LINKS="https://data.pyg.org/whl/torch-2.7.0+cu128.html"

COPY environment.yml .
COPY condarc ${MAMBA_ROOT_PREFIX}
RUN micromamba install -y -n base -f /tmp/environment.yml && \
    micromamba clean --all --yes

