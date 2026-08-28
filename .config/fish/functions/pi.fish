function pi
    set -l bin (command -s pi)
    command bun $bin $argv
end
