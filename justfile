update:
    sudo pacman -Syu --noconfirm
    paru -Syu --noconfirm
    herdr update
    bun update -g omp
    ya pack -u
    # nvim --headless "+PackUpdate" +qa
    @echo "✓ Mise à jour terminée"
