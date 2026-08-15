FROM docker.io/archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm --needed \
        base-devel git curl wget sudo just

# makepkg/paru refusent de tourner en root
RUN useradd -m -G wheel builder && \
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel && \
    chmod 0440 /etc/sudoers.d/wheel

USER builder
WORKDIR /home/builder
RUN git clone https://aur.archlinux.org/paru.git && \
    cd paru && \
    makepkg -si --noconfirm && \
    cd .. && \
    rm -rf paru

RUN paru -S --noconfirm herdr bun ttf-hack-nerd grex

USER root

RUN pacman -S --noconfirm --needed \
        fish starship kitty yazi \
        bat eza zoxide skim ripgrep fd \
        bandwhich btop difftastic procs trash-cli \
        neovim

RUN BUN_INSTALL=/usr/local bun install -g omp
