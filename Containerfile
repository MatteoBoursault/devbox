# Image de la devbox : conteneur Arch Linux avec tous les outils préinstallés.
# Construire l'image : podman build -t devbox .

FROM docker.io/archlinux:latest

# Base système + dépendances de compilation des paquets AUR
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm --needed \
        base-devel git curl wget sudo just

# Utilisateur non-root requis par makepkg/paru
RUN useradd -m -G wheel builder && \
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel && \
    chmod 0440 /etc/sudoers.d/wheel

# Helper AUR : paru
USER builder
WORKDIR /home/builder
RUN git clone https://aur.archlinux.org/paru.git && \
    cd paru && \
    makepkg -si --noconfirm && \
    cd .. && \
    rm -rf paru

# Paquets AUR
RUN paru -S --noconfirm herdr bun

USER root

# Shell, terminal, gestionnaire de fichiers, outils CLI et éditeur
RUN pacman -S --noconfirm --needed \
        fish starship \
        kitty \
        yazi \
        bat eza zoxide skim ripgrep fd \
        bandwhich btop difftastic procs \
        neovim

# omp (harnais llm) installé globalement dans le PATH système
RUN BUN_INSTALL=/usr/local bun install -g omp
