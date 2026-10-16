# Fresh Ubuntu 24.04 box for testing the dotfiles bootstrap (oathbringer-like).
# The image ships a non-root `ubuntu` user (UID 1000) since 23.04; reuse it.
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sudo git curl ca-certificates gpg zsh locales && \
    rm -rf /var/lib/apt/lists/*

RUN echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu && \
    chsh -s /bin/zsh ubuntu

USER ubuntu
WORKDIR /home/ubuntu
ENV TERM=xterm-256color LANG=C.UTF-8 SHELL=/bin/zsh
