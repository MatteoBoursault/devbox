# Ne pas mettre à jour herdr depuis une instance herdr
herdr_update := if env_var_or_default("HERDR_ENV", "") == "1" {
  "echo \"Dans une instance herdr : mise à jour de herdr ignorée\""
} else {
  "herdr update"
}

update:
    sudo pacman -Syu --noconfirm
    paru -Syu --noconfirm
    # TODO_devbox : rustup update
    {{ herdr_update }}
    bun update -g
    ya pkg install --discard
    ya pkg upgrade
    ./scripts/patch-faster-piper.sh
    nvim --headless "+lua vim.pack.update(nil, { force = true })" +qa
    bat cache --build
    @echo "✓ Mise à jour terminée"
