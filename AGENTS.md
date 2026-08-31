# AGENTS

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

## Conventions

- Un fix temporaire se documente par un commentaire « TODO_devbox : … » qui explique pourquoi il existe.
