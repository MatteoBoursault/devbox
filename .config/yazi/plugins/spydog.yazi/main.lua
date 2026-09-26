-- spydog.yazi — observabilité des événements yazi (cd, move, delete, rename, trash).
-- L'ouverture de fichier ("open") est loggée via l'opener edit → scripts/spydog-open,
-- pas ici : yazi n'émet aucun event DDS à l'ouverture (open est une action, pas un événement).

local function log(type_, value)
  ya.async(function()
    Command("spydog-hook"):arg({ "yazi", type_, ya.json_encode(value) }):status()
  end)
end

local function urls_to_strings(urls)
  local out = {}
  for _, u in ipairs(urls or {}) do
    out[#out + 1] = tostring(u)
  end
  return out
end

return {
  setup = function()
    ps.sub("cd", function()
      log("cd", { url = tostring(cx.active.current.cwd) })
    end)

    ps.sub("move", function(body)
      local items = {}
      for _, it in ipairs(body and body.items or {}) do
        items[#items + 1] = { from = tostring(it.from), to = tostring(it.to) }
      end
      log("move", { items = items })
    end)

    ps.sub("delete", function(body)
      log("delete", { urls = urls_to_strings(body and body.urls) })
    end)

    ps.sub("trash", function(body)
      log("trash", { urls = urls_to_strings(body and body.urls) })
    end)

    ps.sub("rename", function(body)
      if body and body.from and body.to then
        log("rename", { from = tostring(body.from), to = tostring(body.to) })
      end
    end)
  end,
}
