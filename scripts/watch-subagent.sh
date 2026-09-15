#!/bin/sh
# Attend la fin d'un sous-agent pi, vérifie result.json (le redemande sinon),
# ferme l'onglet et réveille l'orchestrateur ; result.json de secours à la deadline.
# Usage : watch-subagent.sh <run_id> <agent> <run_dir> <pane_id> <tab_id> <orchestrator_pane_id>
set -u

run_id=${1:-}
agent=${2:-}
run_dir=${3:-}
pane=${4:-}
tab=${5:-}
orch=${6:-}
if [ -z "$run_id" ] || [ -z "$agent" ] || [ -z "$run_dir" ] || [ -z "$pane" ] || [ -z "$tab" ] || [ -z "$orch" ]; then
  echo "usage: watch-subagent.sh <run_id> <agent> <run_dir> <pane_id> <tab_id> <orchestrator_pane_id>" >&2
  exit 1
fi

result="$run_dir/result.json"
# 15 min
deadline_s=$(($(date +%s) + 900))
max_prompts=2
prompts=0

wake() {
  herdr agent prompt "$orch" "Sous-agent $agent terminé (run $run_id). Lis $run_dir/result.json et intègre le résultat." >/dev/null 2>&1
}

fail_timeout() {
  [ -f "$result" ] || printf '%s\n' \
    "{\"run_id\":\"$run_id\",\"agent\":\"$agent\",\"status\":\"failure\",\"summary\":\"timeout ou absence de result.json\",\"artifacts\":[],\"error\":\"timeout\"}" \
    >"$result"
}

while :; do
  remain_s=$((deadline_s - $(date +%s)))
  [ "$remain_s" -le 0 ] && break

  herdr agent wait "$pane" --until idle --until done --until blocked --timeout $((remain_s * 1000)) >/dev/null 2>&1 || true

  [ -f "$result" ] && break

  status=$(herdr agent get "$pane" 2>/dev/null | grep -o '"agent_status": *"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
  case "$status" in
  blocked)
    herdr agent send-keys "$pane" esc >/dev/null 2>&1 || true
    ;;
  idle | done)
    if [ "$prompts" -lt "$max_prompts" ]; then
      prompts=$((prompts + 1))
      herdr agent prompt "$pane" "Tu as fini mais $result est absent. Écris-le via l'outil write (format exact du protocole)." >/dev/null 2>&1 || true
    else
      break
    fi
    ;;
  *)
    ;; # working/unknown
  esac

  sleep 1 # anti-spin
done

fail_timeout
herdr tab close "$tab" >/dev/null 2>&1 || true
wake
