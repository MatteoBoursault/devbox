---
name: sync-agents
description: >
  Promotes only the durable content of USER.md (preferences, conventions,
  behavioral rules) into AGENTS.md, the repo's versioned source of truth that
  Pi auto-loads at startup. Trigger only on explicit user request ("sync
  AGENTS.md", "mets mes préférences dans AGENTS.md"). Never auto-runs, never
  commits.
---

# Sync AGENTS

Promotes durable user preferences from the agent's working memory (USER.md)
into AGENTS.md, the versioned source of truth that Pi auto-loads at startup.

## When to Use

Only when the user explicitly asks to update AGENTS.md. Never automatically.

## Procedure

1. Read USER.md (and failures.md for stable conventions/corrections).
2. Filter: keep only durable content (see Rules).
3. Read the current AGENTS.md; merge without duplicating existing entries.
4. Apply short, targeted edits: modify only the lines or sections that change,
   leave the rest of the file untouched.
5. Show a summary of additions/removals for review.

## Rules — keep

- Durable preferences.
- Stable conventions and behavioral rules for the agent.
- Correction-based lessons that are stable, not one-off.

## Rules — drop

- One-off TODOs and temporary fixes.
- Environment/technical facts.
- Duplicates already present in AGENTS.md.
- Timestamps (`<!-- created=… -->`) and `§` separators.

## Format

Clean Markdown prose in sections (Code, Git, Conduite, Conventions…).
Human-readable, no timestamps, no `§`. AGENTS.md is read every session.

## Verification

- AGENTS.md contains only durable, non-duplicated entries.
- No timestamp or `§` markers remain.
- Only the targeted lines changed (minimal diff).
- Nothing was committed; the user reviews and commits.
