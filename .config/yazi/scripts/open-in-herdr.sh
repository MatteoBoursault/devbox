#!/bin/sh
# Ouvre chaque fichier dans un nouvel onglet herdr, sans bloquer yazi.
# Utilisé par l'opener `edit` de yazi (voir yazi.toml), avec un ou plusieurs
# chemins en arguments. Nécessite de tourner dans une session herdr.
#
# TODO_devbox: herdr (version officielle) ne sait lancer qu'un shell dans un
# nouvel onglet, pas une commande directe (issue herdrdev/herdr#1695). On passe
# donc le fichier via `--env HERDR_OPEN_FILE`, et config.fish l'ouvre au
# démarrage du shell (avant l'invite) → pas de course au démarrage ni de
# dépendance au prompt. À remplacer par `pane.split --argv` (ou équivalent)
# quand herdr l'aura ajouté.

for file in "$@"; do
  dir=$(dirname -- "$file")
  label=$(basename -- "$file")

  # Crée l'onglet dans le workspace courant ; config.fish ouvre HERDR_OPEN_FILE.
  herdr tab create --cwd "$dir" --label "$label" --focus --env "HERDR_OPEN_FILE=$file"
done
