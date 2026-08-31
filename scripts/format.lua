#!/usr/bin/env luajit
-- format.lua [<dir>] | --staged — formateurs définis dans .config/language/languages.lua

local function q(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function realpath(p)
  return io.popen("readlink -f -- " .. q(p)):read("*a"):gsub("%s+$", "")
end

-- dossier racine du devbox, déduit de l'emplacement du script (indépendant du cwd et de git)
local script_dir = arg[0]:match("^(.*)/") or "."
local devdir = realpath(script_dir .. "/..")
local M = dofile(devdir .. "/.config/language/languages.lua")

-- répertoire des configs des formatters : jamais formaté (auto-formatage impossible)
local config_dir = devdir .. "/.config/language/"

-- extension → formatter
local by_ext = {}
for _, fmt in pairs(M.formatters) do
  for _, e in ipairs(fmt.exts) do
    by_ext[e] = fmt
  end
end

local function file_hash(f)
  local p = io.popen("md5sum -- " .. q(f) .. " 2>/dev/null")
  local h = p:read("*a"):match("^(%x+)")
  p:close()
  return h
end

local function run(fmt, files)
  local argv = { fmt.cmd }
  for _, t in ipairs({ fmt.args, fmt.config, fmt.write }) do
    for _, a in ipairs(t or {}) do
      argv[#argv + 1] = a
    end
  end
  for _, f in ipairs(files) do
    argv[#argv + 1] = f
  end
  for i, a in ipairs(argv) do
    argv[i] = q(a)
  end
  local before = {}
  for _, f in ipairs(files) do
    before[f] = file_hash(f)
  end
  -- stdout+stderr du formatter → fichier temporaire, montré seulement en cas d'échec
  local log = os.tmpname()
  local ok = os.execute(table.concat(argv, " ") .. " >" .. q(log) .. " 2>&1")
  if ok ~= 0 then
    local f = io.open(log, "r")
    if f then
      io.stderr:write(f:read("*a"))
      f:close()
    end
    os.remove(log)
    io.stderr:write("⚠ " .. fmt.cmd .. " a échoué\n")
    os.exit(1)
  end
  os.remove(log)
  local changed = 0
  for _, f in ipairs(files) do
    if file_hash(f) ~= before[f] then
      changed = changed + 1
    end
  end
  io.write(("→ %s : %d modifié(s) / %d scanné(s)\n"):format(fmt.cmd, changed, #files))
end

local function group(paths)
  local g = {}
  for _, p in ipairs(paths) do
    local fmt = by_ext[p:match("%.([^.]+)$") or ""]
    if fmt then
      g[fmt] = g[fmt] or {}
      g[fmt][#g[fmt] + 1] = p
    end
  end
  return g
end

-- collecte des chemins : --staged (nécessite git) ou répertoire (aucun git)
local paths, gitroot = {}, nil
if arg[1] == "--staged" then
  gitroot = io.popen("git rev-parse --show-toplevel 2>/dev/null"):read("*a"):match("%S+")
  if not gitroot then
    io.stderr:write("erreur : --staged nécessite un dépôt git\n")
    os.exit(1)
  end
  for l in
    io.popen("git -C " .. q(gitroot) .. " diff --cached --name-only --diff-filter=ACM"):lines()
  do
    paths[#paths + 1] = gitroot .. "/" .. l
  end
else
  for l in io.popen("fd -H -E .git . " .. q(realpath(arg[1] or "."))):lines() do
    paths[#paths + 1] = l
  end
end

-- exclut les configs des formatters (chemin absolu)
local filtered = {}
for _, p in ipairs(paths) do
  if p:sub(1, #config_dir) ~= config_dir then
    filtered[#filtered + 1] = p
  end
end
local grouped = group(filtered)
for fmt, files in pairs(grouped) do
  run(fmt, files)
end

if gitroot and next(grouped) then
  local add = { "git", "-C", gitroot, "add", "--" }
  for _, files in pairs(grouped) do
    for _, f in ipairs(files) do
      add[#add + 1] = f
    end
  end
  for i, a in ipairs(add) do
    add[i] = q(a)
  end
  os.execute(table.concat(add, " "))
end
