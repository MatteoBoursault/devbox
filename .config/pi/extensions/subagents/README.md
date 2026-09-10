# Extension sous-agents

Un sous-agent = un processus `pi` complet (TUI visible dans un onglet herdr, shell +
filesystem réels), piloté par cette extension maison. Remplace le paquet npm `pi-subagents`
— aucune dépendance npm.

## Pourquoi

- Sous-agents = processus pi séparés (isolation, shell + fichiers réels, onglet herdr visible).
- Mécanisme simple et maîtrisé (une extension + des `.md` + un script réutilisé).

## Fonctionnement

L'extension :

1. au `before_agent_start`, injecte une section `## Sous-agents disponibles` (nom +
   description de chaque agent) dans le system prompt de l'orchestrateur ;
2. enregistre l'outil `delegate` `{ agent, task }`, qui :
   - résout l'agent `.md` par `name`, parse `skills` / `tools` / `model` ;
   - résout les noms de skills → chemins (via les skills chargés) ;
   - crée le run dir, écrit `task.md` + `protocol.md` ;
   - lance `pi` en mode interactif dans un nouvel onglet herdr ;
   - retourne `{ run_id, run_dir }` sans attendre (asynchrone).

En fin de tâche, le sous-agent écrit `result.json`, réveille l'orchestrateur
(`herdr agent prompt`), puis ferme son onglet (`herdr tab close`).

## Utiliser un sous-agent

L'outil `delegate` :

- `agent` : nom de l'agent (section « Sous-agents disponibles ») ;
- `task` : consigne complète et autonome — le sous-agent ne voit pas ta conversation.

L'appel retourne `run_id` + `run_dir` immédiatement. Au message de réveil, lis
`<run_dir>/result.json`, puis les artefacts dans `<run_dir>/artifacts/`.

## Définir un agent

Un agent = un fichier `~/.config/pi/agents/<name>.md` :

```yaml
---
name: scout
description: Explore rapidement le code et renvoie un contexte compressé. Ne modifie rien.
tools: read,grep,find,ls        # optionnel : restriction réelle (--tools)
# skills: ponytail-review       # optionnel : noms de skills (seules leurs descriptions sont injectées)
# model: provider/id            # optionnel : défaut = modèle courant de l'orchestrateur
---
# Rôle
… corps injecté au sous-agent …
```

| Champ | Requis | Description |
|---|---|---|
| `name` | oui | identifiant passé à `delegate` |
| `description` | oui | injectée dans « Sous-agents disponibles » |
| `tools` | non | liste d'outils (restriction réelle). Sans champ = tous les outils |
| `skills` | non | noms de skills ; seules leurs descriptions sont injectées au sous-agent |
| `model` | non | `provider/id` ; défaut = modèle courant de l'orchestrateur |

> `bash` est **automatiquement ajouté** aux tools : le protocol de fin (réveil +
> fermeture d'onglet) passe par des commandes herdr.

## Commande du sous-agent

```sh
pi @<run>/task.md \
   --append-system-prompt @<agent>.md \
   --append-system-prompt @<run>/protocol.md \
   --no-skills --skill <p1> --skill <p2> \
   --tools <list> \
   --no-session \
   [--model provider/id]
```

Mode interactif (pas de `-p`) : le TUI pi du sous-agent est visible dans l'onglet herdr
(pensées, appels d'outils).

## Protocol de fin

En fin de tâche (succès ou échec), le sous-agent doit :

1. déposer ses artefacts dans `artifacts/` ;
2. écrire `result.json` ;
3. réveiller l'orchestrateur :
   `herdr agent prompt <pane> "Sous-agent <agent> terminé. Lis <run_dir>/result.json et intègre le résultat."` ;
4. fermer son onglet : `herdr tab close $HERDR_TAB_ID`.

## `result.json`

```json
{ "run_id": "…", "agent": "…", "status": "success|failure",
  "summary": "…", "artifacts": ["artifacts/x"], "error": null }
```

## Réveil de l'orchestrateur

`herdr agent prompt <pane> "<message>"` — injecte un message dans l'input de l'orchestrateur.

- idle → nouveau tour (lit le résultat) ;
- en cours → pi met en file (follow-up) ;
- bloqué (approbation/question) → herdr rejette `agent_blocked` (pas de fallback, connu).

## Runs

Chaque délégation écrit dans `~/.cache/pi/subagents/runs/<run-id>/` : `task.md`,
`protocol.md`, `result.json`, `artifacts/`.

## Échecs

- Échec auto-déclaré → `result.json` `status: failure` + `error`.
- Crash / hang → pas de `result.json` ; l'onglet reste ouvert (visible). Pas de timeout en v1.

## Fichiers

- Extension : `~/.config/pi/extensions/subagents/` (ce dossier)
- Agents : `~/.config/pi/agents/<name>.md`
- Playbook : `~/.config/pi/skills/delegate/SKILL.md`
- Runs : `~/.cache/pi/subagents/runs/<run-id>/`
- Script de lancement (réutilisé) : `~/scripts/launch-in-herdr.sh`
