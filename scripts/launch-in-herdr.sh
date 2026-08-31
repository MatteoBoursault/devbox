#!/bin/sh
# Exécute une commande complète dans un nouvel onglet herdr, avec le label donné.
# Usage : launch-in-herdr.sh <label> <commande complète...>
#   ex. : launch-in-herdr.sh nvim $EDITOR foo.py
# Nécessite de tourner dans une session herdr.
#
# TODO_devbox: herdr (version officielle) ne sait lancer qu'un shell dans un
# nouvel onglet, pas une commande directe (discussion herdrdev/herdr#1695). On passe
# donc la commande via `--env HERDR_LAUNCH_CMD`, et config.fish l'exécute au
# démarrage du shell (avant l'invite) → pas de course ni de dépendance au prompt.
# À remplacer par `pane.split --argv` (ou équivalent) quand herdr l'aura ajouté.

label="$1"
shift
cmd="$*"

if [ -z "$label" ] || [ -z "$cmd" ]; then
  echo "usage: launch-in-herdr.sh <label> <commande...>" >&2
  exit 1
fi

herdr tab create --cwd "$PWD" --label "$label" --focus --env "HERDR_LAUNCH_CMD=$cmd"
