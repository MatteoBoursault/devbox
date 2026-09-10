// Extension de sous-agents : délègue une tâche à un processus pi séparé lancé
// dans un onglet herdr. Source de vérité : ~/subagent.md (tant que l'extension
// n'est pas figée).
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const HOME = process.env.HOME ?? homedir();
const AGENT_DIR = process.env.PI_CODING_AGENT_DIR
  ? join(process.env.PI_CODING_AGENT_DIR, "agents")
  : join(HOME, ".config", "pi", "agents");
const RUNS_ROOT = join(HOME, ".cache", "pi", "subagents", "runs");
const LAUNCH_SCRIPT = join(HOME, "scripts", "launch-in-herdr.sh");

interface AgentDef {
  name: string;
  description: string;
  file: string;
  skills: string[];
  tools: string[];
  model?: string;
}

/** Extrait le frontmatter YAML (clé: valeur plats) d'un .md. */
function parseFrontmatter(raw: string): Record<string, string> {
  const data: Record<string, string> = {};
  const m = raw.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!m) return data;
  for (const line of m[1].split(/\r?\n/)) {
    const idx = line.indexOf(":");
    if (idx <= 0) continue;
    let value = line.slice(idx + 1).trim();
    value = value.replace(/^["']|["']$/g, ""); // guillemets d'entourage
    value = value.replace(/\s+#.*$/, "").trim(); // commentaire inline
    data[line.slice(0, idx).trim()] = value;
  }
  return data;
}

function loadAgents(): AgentDef[] {
  if (!existsSync(AGENT_DIR)) return [];
  return readdirSync(AGENT_DIR)
    .filter((f) => f.endsWith(".md"))
    .map((f) => {
      const file = join(AGENT_DIR, f);
      const fm = parseFrontmatter(readFileSync(file, "utf8"));
      return {
        name: fm.name ?? f.replace(/\.md$/, ""),
        description: fm.description ?? "",
        file,
        skills: (fm.skills ?? "")
          .split(",")
          .map((s) => s.trim())
          .filter(Boolean),
        tools: (fm.tools ?? "")
          .split(",")
          .map((s) => s.trim())
          .filter(Boolean),
        model: fm.model || undefined,
      };
    })
    .filter((a) => a.name && a.description);
}

function buildProtocol(agent: AgentDef, runId: string, runDir: string): string {
  const pane = process.env.HERDR_PANE_ID ?? "";
  return [
    "Tu es un sous-agent lancé par l'outil delegate.",
    `- run_id: ${runId}`,
    `- run_dir: ${runDir}`,
    "",
    "À la fin de ta tâche (succès ou échec) :",
    `1. Dépose tes artefacts dans ${runDir}/artifacts/.`,
    `2. Écris ${runDir}/result.json au format exact :`,
    `   {"run_id":"${runId}","agent":"${agent.name}","status":"success","summary":"…","artifacts":["artifacts/…"],"error":null}`,
    '   (status = "failure" et error renseigné si échec)',
    "3. Réveille l'orchestrateur :",
    `   herdr agent prompt ${pane} "Sous-agent ${agent.name} terminé. Lis ${runDir}/result.json et intègre le résultat."`,
    "4. Ferme ton onglet herdr (ceci termine le sous-agent) :",
    "   herdr tab close $HERDR_TAB_ID",
  ].join("\n");
}

export default function (pi: ExtensionAPI) {
  const skillPaths = new Map<string, string>(); // nom de skill → chemin
  let agentList: AgentDef[] = [];

  pi.on("before_agent_start", (event) => {
    // Carte nom→chemin des skills chargés (pour résoudre les skills des agents).
    skillPaths.clear();
    for (const s of event.systemPromptOptions.skills ?? []) {
      skillPaths.set(s.name, s.filePath);
    }

    agentList = loadAgents();
    if (agentList.length === 0) return;

    const section = [
      "## Sous-agents disponibles",
      "",
      "Délègue les tâches substantielles et indépendantes à un processus pi séparé via l'outil `delegate`. Résultat asynchrone : un message de réveil arrivera, puis lis `<run_dir>/result.json`.",
      "",
      ...agentList.map((a) => `- **${a.name}** : ${a.description}`),
    ];
    return { systemPrompt: event.systemPrompt + "\n\n" + section.join("\n") };
  });

  pi.registerTool({
    name: "delegate",
    label: "Delegate",
    description:
      "Délègue une tâche à un sous-agent (processus pi séparé lancé dans un onglet herdr). Prend `agent` (nom dans « Sous-agents disponibles ») et `task` (consigne autonome avec contexte). Retourne run_id/run_dir immédiatement ; le résultat arrive de façon asynchrone.",
    promptSnippet: "Délègue une tâche bornée à un sous-agent (processus pi séparé, asynchrone).",
    parameters: Type.Object({
      agent: Type.String({
        description: "Nom de l'agent à déléguer (voir « Sous-agents disponibles »).",
      }),
      task: Type.String({
        description:
          "Tâche complète et autonome : contexte + livrable. Le sous-agent ne voit pas ta conversation.",
      }),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      const { agent: agentName, task } = params;

      if (process.env.HERDR_ENV !== "1") {
        throw new Error("delegate nécessite une session herdr (HERDR_ENV=1).");
      }

      const agent = (agentList.length ? agentList : loadAgents()).find((a) => a.name === agentName);
      if (!agent) {
        const available = (agentList.length ? agentList : loadAgents())
          .map((a) => a.name)
          .join(", ");
        throw new Error(`Agent inconnu : « ${agentName} ». Disponibles : ${available || "aucun"}.`);
      }

      const skillArgs: string[] = [];
      for (const sname of agent.skills) {
        const p = skillPaths.get(sname);
        if (!p) throw new Error(`Skill « ${sname} » introuvable pour l'agent « ${agentName} ».`);
        skillArgs.push("--skill", p);
      }

      const runId = `${agentName}-${Date.now()}`;
      const runDir = join(RUNS_ROOT, runId);
      mkdirSync(join(runDir, "artifacts"), { recursive: true });
      writeFileSync(join(runDir, "task.md"), task);
      writeFileSync(join(runDir, "protocol.md"), buildProtocol(agent, runId, runDir));

      const args = [
        "pi",
        `@${join(runDir, "task.md")}`,
        "--append-system-prompt",
        `@${agent.file}`,
        "--append-system-prompt",
        `@${join(runDir, "protocol.md")}`,
        "--no-skills",
        ...skillArgs,
      ];
      if (agent.tools.length) {
        const tools = agent.tools.includes("bash") ? agent.tools : [...agent.tools, "bash"];
        args.push("--tools", tools.join(","));
      }
      const model =
        agent.model ?? (ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : undefined);
      if (model) args.push("--model", model);
      args.push("--no-session", "--approve");

      const res = await pi.exec(LAUNCH_SCRIPT, [`agent:${agentName}`, args.join(" ")], {
        cwd: ctx.cwd,
      });
      if (res.code !== 0) {
        throw new Error(`Échec du lancement herdr : ${res.stderr || res.stdout}`);
      }

      return {
        content: [
          {
            type: "text",
            text: `Sous-agent « ${agentName} » lancé (run ${runId}).\nrun_dir: ${runDir}\nRésultat attendu dans ${join(runDir, "result.json")} — un message de réveil arrivera à la fin.`,
          },
        ],
        details: { run_id: runId, run_dir: runDir, agent: agentName },
      };
    },
  });
}
