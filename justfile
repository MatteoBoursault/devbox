update:
    sudo pacman -Syu --noconfirm
    paru -Syu --noconfirm
    bun update -g omp
    ya pack -u
    # nvim --headless "+PackUpdate" +qa
    @echo "✓ Mise à jour terminée"
