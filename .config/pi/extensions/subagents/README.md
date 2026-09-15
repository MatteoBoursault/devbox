# Extension sous-agents

Un sous-agent = un processus `pi` complet (TUI visible dans un onglet herdr, shell +
filesystem réels), piloté par cette extension maison. Aucune dépendance npm.

## Pourquoi

- Sous-agents = processus pi séparés (isolation, shell + fichiers réels, onglet herdr visible).
- Mécanisme simple et maîtrisé (une extension + des `.md` + deux scripts).

## Fonctionnement

L'extension :

1. au `before_agent_start`, injecte une section `## Sous-agents disponibles` (nom +
   description de chaque agent) dans le system prompt de l'orchestrateur ;
2. enregistre l'outil `delegate` `{ agent, task }`, qui :
   - résout l'agent `.md` par `name`, parse `skills` / `tools` / `model` ;
   - résout les noms de skills → chemins (via les skills chargés) ;
   - crée le run dir, écrit `task.md` + `protocol.md` ;
   - lance `pi` en mode interactif dans un nouvel onglet herdr, avec `write-scope.ts`
     et `SUBAGENT_RUN_DIR` pour bloquer toute écriture hors du run dir ;
   - récupère `pane_id`/`tab_id` de l'onglet (sortie de `herdr tab create`) ;
   - détache `watch-subagent.sh` qui supervise la fin du sous-agent ;
   - retourne `{ run_id, run_dir }` sans attendre (asynchrone).

En fin de tâche, le sous-agent écrit `result.json` (outil `write`).
Le watcher détecte le passage en idle/done, vérifie `result.json`, le redemande au
besoin, puis ferme l'onglet et réveille l'orchestrateur. Si le sous-agent crashe,
pend ou oublie, un `result.json` `failure:timeout` est écrit à la deadline.

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
tools: read,grep,find,ls,write   # write est nécessaire pour écrire result.json (scopé au run_dir)
# skills: my-skill            # optionnel : noms de skills chargés dans le sous-agent
# extensions: my-ext         # optionnel : noms d'extensions autorisées (en plus du write-scope)
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
| `skills` | non | noms de skills chargés dans le sous-agent |
| `extensions` | non | noms d'extensions autorisées (en plus du write-scope), résolus dans `~/.config/pi/extensions/` |
| `model` | non | `provider/id` ; défaut = modèle courant de l'orchestrateur |

> Aucun `bash` n'est ajouté automatiquement : la terminaison et le réveil sont
> gérés par le watcher, pas par le sous-agent. Un agent lecture seule a juste
> besoin de `write` (scopé au run_dir) pour déposer `result.json`.

## Commande du sous-agent

```sh
env SUBAGENT_RUN_DIR=<run> pi @<run>/task.md \
   --append-system-prompt <run>/agent-prompt.md \
   --append-system-prompt <run>/protocol.md \
   --no-skills --skill <p1> --skill <p2> \
   --tools <list> \
   --no-extensions --extension <write-scope.ts> --extension <ext1> \
   --no-session --approve \
   [--model provider/id]
```

Mode interactif (pas de `-p`) : le TUI pi du sous-agent est visible dans l'onglet herdr
(pensées, appels d'outils).

## Protocol de fin

En fin de tâche (succès ou échec), le sous-agent écrit `result.json` via l'outil
`write`. Le watcher s'occupe de la terminaison.

## `result.json`

```json
{ "run_id": "…", "agent": "…", "status": "success|failure",
  "summary": "…", "artifacts": ["artifacts/x"], "error": null }
```

## Terminaison (watcher)

`watch-subagent.sh` supervise le sous-agent et garantit une fin déterministe :

1. `herdr agent wait <pane> --until idle|done|blocked` (deadline 15 min) ;
2. `result.json` présent → ferme l'onglet et réveille l'orchestrateur ;
3. absent et sous-agent `idle`/`done` → le redemande via `herdr agent prompt` (2× max) ;
4. `blocked` → `herdr agent send-keys esc` (débloque) ;
5. deadline dépassée → écrit un `result.json` `failure:timeout`, ferme l'onglet, réveille.

Résultat : il y a **toujours** un `result.json` (réel ou timeout) et un réveil,
même en cas de crash ou de hang.

## Réveil de l'orchestrateur

`herdr agent prompt <pane> "<message>"` — injecte un message dans l'input de l'orchestrateur.

- idle → nouveau tour (lit le résultat) ;
- en cours → pi met en file (follow-up) ;
- bloqué (approbation/question) → herdr rejette `agent_blocked`.

## Runs

Chaque délégation écrit dans `~/.cache/pi/subagents/runs/<run-id>/` : `task.md`,
`protocol.md`, `result.json`, `artifacts/`.

## Échecs

- Échec auto-déclaré → `result.json` `status: failure` + `error`.
- Crash / hang / oubli → le watcher écrit un `result.json` `failure:timeout` à la
  deadline (15 min), ferme l'onglet et réveille. Pas de sous-agent orphelin.

## Fichiers

- Extension : `~/.config/pi/extensions/subagents/` (ce dossier)
- Blocage d'écriture : `~/.config/pi/extensions/subagents/write-scope.ts`
- Agents : `~/.config/pi/agents/<name>.md`
- Playbook : `~/.config/pi/skills/delegate/SKILL.md`
- Runs : `~/.cache/pi/subagents/runs/<run-id>/`
- Script de lancement : `~/scripts/launch-in-herdr.sh`
- Watcher : `~/scripts/watch-subagent.sh`
