#!/bin/sh
# Aperçu live d'un fichier .d2 : rendu PNG (d2 --watch) redessiné à chaque changement.
# Usage : d2-preview.sh <fichier.d2>   (Ctrl-C pour quitter)

src=$(readlink -f -- "$1" 2>/dev/null)
if [ -z "$src" ] || [ ! -f "$src" ]; then
  echo "usage: d2-preview.sh <fichier.d2>" >&2
  exit 1
fi

out=${TMPDIR:-/tmp}/d2-preview-$(basename "$src" .d2).png
rm -f "$out"

d2 --watch --browser 0 "$src" "$out" >/dev/null 2>&1 &
watcher=$!
trap 'kill $watcher 2>/dev/null; kitten icat --clear; exit 0' INT TERM HUP

# sondage à 300 ms (inotifywait et entr sont absents de l'image).
# La taille du volet fait partie de la signature, donc un redimensionnement redessine aussi.
# Un rendu en échec ne met pas à jour l'image : le dernier rendu valide reste affiché.
last=
while :; do
  size=$(stty size 2>/dev/null) # "<lignes> <colonnes>"
  rows=${size% *}
  cols=${size#* }
  sig="$cols $rows $(stat -c '%s %y' "$out" 2>/dev/null)"
  if [ -n "$cols" ] && [ -f "$out" ] && [ "$sig" != "$last" ]; then
    kitten icat --clear --place "${cols}x${rows}@0x0" "$out"
    last=$sig
  fi
  sleep 0.3
done
