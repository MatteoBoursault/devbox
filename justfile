update:
    sudo pacman -Syu --noconfirm
    paru -Syu --noconfirm
    rustup update
    herdr update
    bun update -g
    ya pkg upgrade
    # nvim --headless "+PackUpdate" +qa
    @echo "✓ Mise à jour terminée"
