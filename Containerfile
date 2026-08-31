FROM docker.io/archlinux:latest

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    HERDR_INSTALL_DIR=/usr/local/herdr/bin \
    BUN_INSTALL=/usr/local/bun

ENV PATH=/usr/lib/rustup/bin:$CARGO_HOME/bin:$HERDR_INSTALL_DIR:$BUN_INSTALL/bin:$PATH

RUN pacman -Syu --noconfirm --needed \
  # base
  base-devel git curl wget sudo just ttf-hack-nerd \
  # language framework
  rustup bun \
  # tools
  fish starship kitty yazi neovim \
  bat eza zoxide skim ripgrep fd \
  bandwhich btop difftastic procs trash-cli \
  # lsp/linter/formatter
  uv ruff mypy \
  clang cppcheck \
  stylua luacheck lua-language-server \
  shellcheck shfmt \
  biome taplo-cli yamllint markdownlint-cli

RUN curl -fsSL https://herdr.dev/install.sh | sh

RUN bun add -g --ignore-scripts \
  tree-sitter-cli typescript typescript-language-server \
  node-gyp @earendil-works/pi-coding-agent

RUN rustup default stable && \
    rustup component add clippy rustfmt rust-analyzer rust-src && \
    mkdir -p $CARGO_HOME && chmod -R a+rwX $CARGO_HOME

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
RUN paru -S --noconfirm grex rtk-bin

USER root
RUN chmod -R a+rwX $RUSTUP_HOME $CARGO_HOME $HERDR_INSTALL_DIR $BUN_INSTALL
RUN pacman -Scc --noconfirm
