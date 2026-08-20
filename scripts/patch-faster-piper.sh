#!/bin/sh
# TODO_devbox
# faster-piper : l'épinglage =8b794bf (package.toml) est nécessaire car @latest
# exige yazi ≥ 26.8.15, pas encore dans Arch (yazi 26.5.6 installé).
#
# Ce script installe le plugin épinglé si besoin, puis applique le backport du
# correctif amont « Release the cache lock when Yazi cancels a peek »
# (commit 24a049d1), absent de 8b794bf. Sans lui, un peek remplacé par Yazi
# laisse son verrou en place : les previews suivantes du fichier restent
# bloquées (« faster-piper:locked-timeout ») jusqu'à expiration du TTL (60 s).
#
# À relancer après tout `ya pkg install` / `ya pkg upgrade` qui réinstalle le
# plugin. Supprimer ce script (ainsi que le flag --discard des commandes ya pkg)
# quand Arch aura yazi ≥ 26.8.15 et que le pin sera levé.
set -e
DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN="$HOME/.config/yazi/plugins/faster-piper.yazi"

# État stable : plugin présent et déjà patché → rien à faire (évite le message
# « operation has been aborted » de `ya pkg install` sur plugin modifié).
if [ -f "$PLUGIN/main.lua" ] && grep -q "local function instance_id" "$PLUGIN/main.lua"; then
  echo "faster-piper: déjà installé et patché"
  exit 0
fi

ya pkg install

if [ ! -f "$PLUGIN/main.lua" ]; then
  echo "faster-piper: plugin introuvable après ya pkg install ($PLUGIN)" >&2
  exit 1
fi

patch -d "$PLUGIN" -p1 <"$DIR/scripts/faster-piper-26.5.6.patch"
echo "faster-piper: backport appliqué (verrou libéré sur peek annulé)"
