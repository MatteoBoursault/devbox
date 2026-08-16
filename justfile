update:
    sudo pacman -Syu --noconfirm
    paru -Syu --noconfirm
    herdr update
    bun update -g omp
    ya pkg upgrade
    # nvim --headless "+PackUpdate" +qa
    @echo "✓ Mise à jour terminée"
