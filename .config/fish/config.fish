# MODE VI
fish_vi_key_bindings

set -g fish_greeting

# INIT
starship init fish | source
zoxide init fish --cmd cd | source

# ENV
fish_add_path ~/.local/bin
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml
set -gx PI_CODING_AGENT_DIR ~/.config/pi
set -gx EDITOR nvim

# ABBREVIATIONS
abbr -a ls 'eza --icons --group-directories-first'
abbr -a ll 'eza -la --icons --git --group-directories-first'
abbr -a lt 'eza -la --icons --tree --level=2 --group-directories-first'
abbr -a ps 'procs'
abbr -a htop 'btop'
abbr -a find 'fd'
abbr -a grep 'rg'
abbr -a netw 'bandwhich'
abbr -a regex 'grex'
abbr -a rm 'trash'
abbr -a gap 'git commit --amend --no-edit && git push --force-with-lease'

# HISTORY
source ~/.config/fish/functions/skim_key_bindings.fish
bind -M default \cr skim-history-widget
bind -M insert \cr skim-history-widget

# TODO_devbox: herdr (officiel) ne sait lancer qu'un shell dans un nouvel onglet,
# pas une commande directe (herdrdev/herdr#1695). L'opener yazi crée donc l'onglet
# avec `--env HERDR_OPEN_FILE=<fichier>` et on l'ouvre ici, au démarrage du shell
# (avant l'invite) → pas de course. À retirer quand herdr aura `pane.split --argv`.
if set -q HERDR_OPEN_FILE
    set -l file "$HERDR_OPEN_FILE"
    set -e HERDR_OPEN_FILE
    $EDITOR -- "$file"
end
