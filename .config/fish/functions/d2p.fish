function d2p -d "Aperçu d'un fichier .d2 dans le terminal ; -w pour suivre les modifications"
    if test "$argv[1]" = -w; and test (count $argv) -eq 2
        exec d2-preview.sh $argv[2]
    end
    if test (count $argv) -eq 1
        set -l src (readlink -f -- $argv[1])
        set -l out /tmp/d2-(basename $src .d2).png
        d2 $src $out; or return 1
        kitten icat --clear $out
        return
    end
    echo "usage: d2p [-w] <fichier.d2>" >&2
    return 1
end
