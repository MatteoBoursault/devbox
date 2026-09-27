# AGENTS

## Langue

- Répondre en français.

## Environnement

- L'agent tourne dans la devbox, pas sur l'hôte.
- La devbox est une distrobox (conteneur podman Arch Linux). Son HOME `~` (= `$HOME`) est le projet devbox : c'est ICI qu'on le modifie.
- Le home de l'hôte est monté dans la devbox à `$DISTROBOX_HOST_HOME` : les autres projets s'y trouvent et se modifient directement depuis la devbox (pas besoin d'en sortir).
- `/run/host` = racine du système hôte ; `distrobox-host-exec <cmd>` exécute une commande sur l'hôte.
- Partagé avec l'hôte : PID (`ps` voit les processus hôte, PID 1 = systemd de l'hôte) et réseau (mêmes interfaces, même localhost — un serveur lancé ici écoute sur l'IP de l'hôte). `/run` est propre au conteneur : `systemctl` ne pilote PAS l'hôte (répond « offline »).
- `~/.ssh` et `~/.secrets` sont des montages lecture seule depuis l'hôte.

## Code

- Code minimal : pas d'abstraction spéculative, pas de variable redondante, pas de duplication.
- Ne mettre que des commentaires utiles : pas de prose qui paraphrase le code, commenter seulement si l'information n'est pas évidente.
- Source de vérité unique ; co-localiser la config avec ce qu'elle décrit.

## Git

- C'est l'utilisateur qui gère git (commit, push). L'agent ne commit ni ne push de lui-même.

## Conduite

- Vérifier les faits avant d'agir ; ne pas supposer, demander quand un choix se présente.
- L'utilisateur veut suivre précisément ce que fait l'agent et le comprendre.
- Scripts minimaux, qui fonctionnent hors dépôt git quand ce n'est pas nécessaire.
- Ne pas supposer la portée : un élément non confirmé n'est pas implémenté ; le demander ou le laisser en attente.
- Si l'utilisateur abandonne une question par accident, re-poser les mêmes questions (un abandon n'est pas un refus).

## Préférences

- Workflow terminal-first, keybindings adaptées au layout Dvorak for programmers.

## Conventions

- Un fix temporaire se documente par un commentaire « TODO_devbox : … » qui explique pourquoi il existe.
