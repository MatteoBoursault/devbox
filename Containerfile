FROM docker.io/archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm --needed \
        base-devel git curl wget sudo just

# makepkg/paru refusent de tourner en root : on crée un user dédié au build des paquets AUR.
#   -m       : crée son home /home/builder
#   -u 999   : uid de la plage système (< 1000) → aucun risque de collision avec le user
#              runtime (uid de l'hôte, >= 1000) ; distrobox ne le renomme donc pas
#   -G wheel : membre du groupe wheel → bénéficie du sudo NOPASSWD défini ci-dessous
#              (requis par paru pour installer les paquets construits)
# useradd crée aussi son groupe primaire `builder` (gid 999) par défaut.
RUN useradd -m -u 999 -G wheel builder && \
    # wheel = sudo sans mot de passe (nécessaire à paru en non-interactif)
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel && \
    # sudo exige un fichier sudoers non modifiable : root, mode 0440
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
