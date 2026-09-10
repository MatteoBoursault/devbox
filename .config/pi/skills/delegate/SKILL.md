---
name: delegate
description: Quand et comment déléguer une tâche à un sous-agent (processus pi séparé) via l'outil `delegate`. Résultat asynchrone dans result.json.
---

# Délégation à un sous-agent

## Quand déléguer
Tâche substantielle, indépendante, qui gagne à un contexte isolé (relecture, recherche, génération isolée).

## Comment
1. Repère l'agent dans la section « Sous-agents disponibles » du system prompt.
2. Appelle l'outil `delegate` avec :
   - `agent` : nom de l'agent ;
   - `task` : consigne complète et autonome (contexte + livrable). Le sous-agent ne voit pas ta conversation.
3. L'outil retourne `run_id` et `run_dir`. Ne bloque pas : la délégation est asynchrone.

## Résultat
Un message « Sous-agent … terminé » arrive (réveil). Lis alors `<run_dir>/result.json`, puis les artefacts listés dans `artifacts/`.

## Règles
- Une sous-tâche bornée par agent.
- Contexte suffisant dans `task`.
- Ne lis pas le corps d'un agent pour faire le travail toi-même.
