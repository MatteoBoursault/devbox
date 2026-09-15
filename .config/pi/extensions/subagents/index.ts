// Délègue une tâche à un processus pi séparé dans un onglet herdr.
// watch-subagent.sh (détaché) détecte la fin, ferme l'onglet et réveille l'orchestrateur.
import { spawn } from "node:child_process";
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { getAgentDir, parseFrontmatter, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const HOME = process.env.HOME ?? homedir();
const AGENT_DIR = join(getAgentDir(), "agents");
const RUNS_ROOT = join(HOME, ".cache", "pi", "subagents", "runs");
const LAUNCH_SCRIPT = join(HOME, "scripts", "launch-in-herdr.sh");
const WATCH_SCRIPT = join(HOME, "scripts", "watch-subagent.sh");
const WRITE_SCOPE_EXT = join(dirname(fileURLToPath(import.meta.url)), "write-scope.ts");

interface AgentDef {
  name: string;
  description: string;
  body: string;
  skills: string[];
  tools: string[];
  extensions: string[];
  model?: string;
}

/** Normalise une valeur de frontmatter (string "a,b" ou tableau YAML) en liste. */
function parseList(value: unknown): string[] {
  const raw = Array.isArray(value) ? value : typeof value === "string" ? value.split(",") : [];
  return raw
    .filter((x): x is string => typeof x === "string")
    .map((x) => x.trim())
    .filter(Boolean);
}

function resolveExtensionPath(name: string): string | undefined {
  const dir = join(getAgentDir(), "extensions");
  const candidates = [
    join(dir, name, "index.ts"),
    join(dir, name, "index.js"),
    join(dir, `${name}.ts`),
    join(dir, `${name}.js`),
  ];
  return candidates.find((p) => existsSync(p));
}

function loadAgents(): { agents: AgentDef[]; errors: string[] } {
  if (!existsSync(AGENT_DIR)) return { agents: [], errors: [] };
  const agents: AgentDef[] = [];
  const errors: string[] = [];
  for (const f of readdirSync(AGENT_DIR)) {
    if (!f.endsWith(".md")) continue;
    const file = join(AGENT_DIR, f);
    let frontmatter: Record<string, unknown> = {};
    let body = "";
    try {
      const parsed = parseFrontmatter<Record<string, unknown>>(readFileSync(file, "utf8"));
      frontmatter = parsed.frontmatter;
      body = parsed.body;
    } catch (e) {
      errors.push(`${file}: ${e instanceof Error ? e.message : String(e)}`);
      continue;
    }
    const name = typeof frontmatter.name === "string" ? frontmatter.name : f.replace(/\.md$/, "");
    const description = typeof frontmatter.description === "string" ? frontmatter.description : "";
    if (!name || !description) continue;
    agents.push({
      name,
      description,
      body,
      skills: parseList(frontmatter.skills),
      tools: parseList(frontmatter.tools),
      extensions: parseList(frontmatter.extensions),
      model: typeof frontmatter.model === "string" ? frontmatter.model : undefined,
    });
  }
  return { agents, errors };
}

function buildProtocol(agent: AgentDef, runId: string, runDir: string): string {
  return [
    "Tu es un sous-agent lancé par l'outil delegate.",
    `- run_id: ${runId}`,
    `- run_dir: ${runDir}`,
    "",
    "À la fin de ta tâche (succès ou échec) :",
    `1. Dépose tes artefacts dans ${runDir}/artifacts/.`,
    `2. Écris ${runDir}/result.json via l'outil write au format exact :`,
    `   {"run_id":"${runId}","agent":"${agent.name}","status":"success","summary":"…","artifacts":["artifacts/…"],"error":null}`,
    '   (status = "failure" et error renseigné si échec)',
  ].join("\n");
}

export default function (pi: ExtensionAPI) {
  const skillPaths = new Map<string, string>(); // nom de skill → chemin
  let agentList: AgentDef[] = [];

  pi.on("before_agent_start", (event, ctx) => {
    skillPaths.clear();
    for (const s of event.systemPromptOptions.skills ?? []) {
      skillPaths.set(s.name, s.filePath);
    }

    const { agents, errors } = loadAgents();
    for (const err of errors) ctx.ui.notify(`Agent YAML invalide, ignoré : ${err}`, "error");
    agentList = agents;
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
      const orchestratorPane = process.env.HERDR_PANE_ID;
      if (!orchestratorPane) {
        throw new Error("HERDR_PANE_ID introuvable : impossible de réveiller l'orchestrateur.");
      }

      const agents = agentList.length ? agentList : loadAgents().agents;
      const agent = agents.find((a) => a.name === agentName);
      if (!agent) {
        const available = agents.map((a) => a.name).join(", ");
        throw new Error(`Agent inconnu : « ${agentName} ». Disponibles : ${available || "aucun"}.`);
      }

      const skillArgs: string[] = [];
      for (const sname of agent.skills) {
        const p = skillPaths.get(sname);
        if (!p) throw new Error(`Skill « ${sname} » introuvable pour l'agent « ${agentName} ».`);
        skillArgs.push("--skill", p);
      }

      const extArgs: string[] = [];
      for (const ename of agent.extensions) {
        const p = resolveExtensionPath(ename);
        if (!p)
          throw new Error(`Extension « ${ename} » introuvable pour l'agent « ${agentName} ».`);
        extArgs.push("--extension", p);
      }

      const runId = `${agentName}-${Date.now()}`;
      const runDir = join(RUNS_ROOT, runId);
      mkdirSync(join(runDir, "artifacts"), { recursive: true });
      writeFileSync(join(runDir, "task.md"), task);
      writeFileSync(join(runDir, "protocol.md"), buildProtocol(agent, runId, runDir));
      const agentPromptPath = join(runDir, "agent-prompt.md");
      writeFileSync(agentPromptPath, agent.body);

      const args = [
        "pi",
        `@${join(runDir, "task.md")}`,
        "--append-system-prompt",
        agentPromptPath,
        "--append-system-prompt",
        join(runDir, "protocol.md"),
        "--no-skills",
        ...skillArgs,
      ];
      if (agent.tools.length) args.push("--tools", agent.tools.join(","));
      args.push("--no-extensions", "--extension", WRITE_SCOPE_EXT, ...extArgs);
      const model =
        agent.model ?? (ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : undefined);
      if (model) args.push("--model", model);
      args.push("--no-session", "--approve");

      const cmd = ["env", `SUBAGENT_RUN_DIR=${runDir}`, ...args].join(" ");
      const res = await pi.exec(LAUNCH_SCRIPT, [`agent:${agentName}`, cmd], { cwd: ctx.cwd });
      if (res.code !== 0) {
        throw new Error(`Échec du lancement herdr : ${res.stderr || res.stdout}`);
      }

      let paneId: string | undefined;
      let tabId: string | undefined;
      try {
        const out = JSON.parse(res.stdout);
        paneId = out.result?.root_pane?.pane_id;
        tabId = out.result?.tab?.tab_id;
      } catch {}
      if (!paneId || !tabId) {
        throw new Error(
          `IDs herdr introuvables dans la sortie de lancement : ${res.stdout || res.stderr}`,
        );
      }

      const watcher = spawn(
        WATCH_SCRIPT,
        [runId, agentName, runDir, paneId, tabId, orchestratorPane],
        { detached: true, stdio: "ignore" },
      );
      watcher.unref();

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
