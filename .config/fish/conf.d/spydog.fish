# spydog — observabilité des commandes shell

function __spydog_json
    # Échappe une chaîne pour l'inclure dans un JSON valide. Les newlines ne
    # sont pas échappées (fish ne sait pas les remplacer de façon fiable).
    set -l s $argv[1]
    set -l s (string replace -a "\\" "\\\\" -- $s)
    set -l s (string replace -a '"' '\"' -- $s)
    set -l s (string replace -a (printf '\t') '\t' -- $s)
    set -l s (string replace -a (printf '\r') '\r' -- $s)
    printf '"%s"' $s
end

function fish_preexec --on-event fish_preexec
    set -g __spydog_cmd $argv[1]
    spydog-hook fish command_start '{"cmd":'(__spydog_json $argv[1])'}' 2>/dev/null
end

function fish_postexec --on-event fish_postexec
    spydog-hook fish command '{"cmd":'(__spydog_json $__spydog_cmd)',"duration_ms":'$CMD_DURATION',"exit_code":'$status'}' 2>/dev/null
end

function fish_command_not_found
    spydog-hook fish command_not_found '{"cmd":'(__spydog_json $argv[1])'}' 2>/dev/null
    __fish_default_command_not_found_handler $argv[1]
end
