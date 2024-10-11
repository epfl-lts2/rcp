# Getting base image with platform specified (important if you build on Apple Silicon)
FROM --platform=linux/amd64 mambaorg/micromamba:git-73cc7ba-jammy-cuda-12.1.1

USER root
# Installing ssh, rsync, rclone, anaconda, vscode-server
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y sudo rsync rclone zsh git curl wget vim tmux
RUN wget -O- https://aka.ms/install-vscode-server/setup.sh | sh


# Configuring Anaconda

WORKDIR /tmp
ENV MAMBA_ROOT_PREFIX=/opt/conda
ENV MAMBA_DISABLE_LOCKFILE=TRUE


COPY environment.yml .
COPY condarc ${MAMBA_ROOT_PREFIX}
RUN micromamba install -y -n base -f /tmp/environment.yml && \
    micromamba clean --all --yes

