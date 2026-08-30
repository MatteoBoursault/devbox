# Ne pas mettre à jour herdr depuis une instance herdr
herdr_update := if env_var_or_default("HERDR_ENV", "") == "1" {
  "echo \"Dans une instance herdr : mise à jour de herdr ignorée\""
} else {
  "herdr update && \
    herdr completion fish > ~/.config/fish/completions/herdr.fish"
}

update:
    sudo pacman -Syu --noconfirm
    paru -Syu --noconfirm
    # TODO_devbox : rustup update
    {{ herdr_update }}
    bun update -g
    PI_CODING_AGENT_DIR="$HOME/.config/pi" pi update --all
    ya pkg install --discard
    ya pkg upgrade
    ./scripts/patch-faster-piper.sh
    nvim --headless "+lua vim.pack.update(nil, { force = true })" +qa
    @echo "✓ Mise à jour terminée"

setup: update
    bat cache --build
    rtk init -g --agent pi
    git config core.hooksPath githooks
    @echo "✓ Initialisation terminée"
