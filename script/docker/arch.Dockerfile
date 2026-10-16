# Fresh CachyOS (Arch) box for testing the dotfiles bootstrap.
# Falls back to archlinux:base-devel if the CachyOS image is unavailable:
#   docker build --build-arg BASE=archlinux:base-devel ...
ARG BASE=cachyos/cachyos:latest
FROM ${BASE}

# pacman's sandbox can't isolate the network inside a container; without this
# every post-transaction hook logs "command failed to execute correctly"
RUN sed -i '/^\[options\]/a DisableSandboxNetwork' /etc/pacman.conf

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm --needed sudo git zsh base-devel && \
    pacman -Scc --noconfirm

RUN useradd -m -s /bin/zsh tester && \
    echo 'tester ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/tester

USER tester
WORKDIR /home/tester
ENV TERM=xterm-256color LANG=C.UTF-8 SHELL=/bin/zsh
