# spydog-shortcut.py — wrapper kitten : journalise un raccourci kitty puis rejoue
# l'action d'origine via boss.combine (même chemin que l'appui de la touche).
#
# Usage (kitty.conf) : map <key> kitten spydog-shortcut.py <key> <action...>

import json
import os
import subprocess

from kitty.fast_data_types import add_timer


def main(args):
  return {}


def handle_result(args, data, target_window_id, boss):
  key = args[1]
  action = " ".join(args[2:])
  payload = json.dumps({"key": key, "action": action})
  subprocess.Popen([os.path.expanduser("~/scripts/spydog-hook"), "kitty", "shortcut", payload])

  def run(timer_id):
    window = boss.window_id_map.get(target_window_id)
    boss.combine(action, window)

  # Différé d'un tick : évite la ré-entrance dans le dispatch de l'action.
  add_timer(run, 0, False)


handle_result.no_ui = True
