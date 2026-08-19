update:
    sudo pacman -Syu --noconfirm
    paru -Syu --noconfirm
    rustup update
    herdr update
    bun update -g
    ya pkg install
    ya pkg upgrade
    ./scripts/patch-faster-piper.sh
    nvim --headless "+lua vim.pack.update(nil, { force = true })" +qa
    @echo "✓ Mise à jour terminée"
