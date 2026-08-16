# MODE VI
fish_vi_key_bindings

set -g fish_greeting

# INIT
starship init fish | source
zoxide init fish --cmd cd | source

# ENV
fish_add_path ~/.local/bin
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml
set -gx PI_CODING_AGENT_DIR ~/.config/omp

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
