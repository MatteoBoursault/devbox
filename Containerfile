FROM docker.io/archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm --needed \
        base-devel git curl wget sudo just rustup

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:/usr/lib/rustup/bin:$PATH
RUN rustup default stable && \
    rustup component add clippy rustfmt rust-analyzer rust-src && \
    mkdir -p /usr/local/rustup /usr/local/cargo && \
    chmod -R a+rwX /usr/local/rustup /usr/local/cargo # a+rwX pour que le user runtime et le builder compilent sans sudo.

# makepkg/paru refusent de tourner en root : on crée un user dédié au build des paquets AUR.
#   -m       : crée son home /home/builder
#   -u 999   : uid de la plage système (< 1000) → aucun risque de collision avec le user
#              runtime (uid de l'hôte, >= 1000) ; distrobox ne le renomme donc pas
#   -G wheel : membre du groupe wheel → bénéficie du sudo NOPASSWD défini ci-dessous
#              (requis par paru pour installer les paquets construits)
# useradd crée aussi son groupe primaire `builder` (gid 999) par défaut.
RUN useradd -m -u 999 -G wheel builder && \
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel && \
    chmod 0440 /etc/sudoers.d/wheel # sudo exige un fichier sudoers non modifiable : root, mode 0440

USER builder
WORKDIR /home/builder
RUN git clone https://aur.archlinux.org/paru.git && \
    cd paru && \
    makepkg -si --noconfirm && \
    cd .. && \
    rm -rf paru
RUN paru -S --noconfirm grex

USER root
RUN pacman -S --noconfirm --needed \
        fish starship kitty yazi \
        bat eza zoxide skim ripgrep fd \
        bandwhich btop difftastic procs trash-cli \
        neovim tree-sitter-cli bun ttf-hack-nerd
RUN pacman -S --noconfirm --needed \
        uv ruff mypy \
        clang cppcheck \
        stylua luacheck lua-language-server \
        shellcheck shfmt \
        biome taplo-cli yamllint markdownlint-cli

RUN curl -fsSL https://herdr.dev/install.sh | sh

RUN BUN_INSTALL=/usr/local bun install -g omp typescript typescript-language-server
