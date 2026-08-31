function sch -d "rg-based line search via sk, batc preview, open in a herdr tab"
    sk --ansi --no-scrollbar --interactive \
        --cmd 'rg --hidden --smart-case --max-count=1 --line-number {q}' \
        --delimiter : --nth 1 --hide-nth 2.. \
        --preview 'batc {1} {2} --style=numbers --color=always --highlight-line {2}' \
        --preview-window=right:70% \
        --bind 'enter:execute(sh ~/scripts/launch-in-herdr.sh nvim $EDITOR {1})'
end
