// Bloque write/edit hors du run_dir du sous-agent (chargé via --extension, scopé par SUBAGENT_RUN_DIR).
import { resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  const root = process.env.SUBAGENT_RUN_DIR;
  pi.on("tool_call", (event, ctx) => {
    if (!root || (event.toolName !== "write" && event.toolName !== "edit")) return undefined;
    const target = resolve(ctx.cwd, (event.input.path as string) ?? "");
    const inside = target === root || target.startsWith(root + "/");
    return inside
      ? undefined
      : { block: true, reason: `Écriture hors run_dir refusée : ${target}` };
  });
}
