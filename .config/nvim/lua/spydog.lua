-- spydog — observabilité nvim
local M = {}

local function log(type_, payload)
  vim.fn.jobstart({ "spydog-hook", "nvim", type_, payload }, { detach = true })
end

-- Logge l'utilisation d'un raccourci défini via Nmap/Vmap/Nvmap.
function M.shortcut(mode, lhs, desc)
  log(
    "shortcut",
    vim.json.encode({
      lhs = lhs,
      desc = desc or "",
      mode = mode,
      ft = vim.bo.filetype,
      file = vim.fn.expand("%"),
    })
  )
end

-- Enveloppe un rhs : journalise puis rejoue l'action d'origine.
function M.wrap(mode, lhs, desc, rhs)
  if type(rhs) == "function" then
    return function()
      M.shortcut(mode, lhs, desc)
      return rhs()
    end
  end
  local keys = vim.api.nvim_replace_termcodes(rhs, true, false, true)
  return function()
    M.shortcut(mode, lhs, desc)
    vim.api.nvim_feedkeys(keys, "nx", false)
  end
end

-- Collage : logge le contenu du registre effectif (celui que p/P va coller).
local function paste()
  local text = vim.fn.getreg(vim.v.register)
  if text == "" then
    return
  end
  -- ignore les échanges triviaux (une ligne courte) → bruit
  if not text:find("\n") and #text < 40 then
    return
  end
  log(
    "paste",
    vim.json.encode({
      text = text,
      ft = vim.bo.filetype,
      file = vim.fn.expand("%"),
    })
  )
end

function M.setup()
  local augroup = vim.api.nvim_create_augroup("Spydog", { clear = true })

  for _, key in ipairs({ "p", "P" }) do
    for _, mode in ipairs({ "n", "v" }) do
      vim.keymap.set(mode, key, function()
        paste()
        return key
      end, { desc = "Paste", expr = true, silent = true, noremap = true })
    end
  end

  -- Ouverture de fichier + snapshot pour le delta au save.
  local snapshots = {}

  vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    desc = "spydog: open + snapshot",
    callback = function(ev)
      snapshots[ev.buf] = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
      log(
        "open",
        vim.json.encode({
          file = vim.fn.expand("%"),
          ft = vim.bo.filetype,
        })
      )
    end,
  })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    desc = "spydog: save_delta",
    callback = function(ev)
      local old = snapshots[ev.buf]
      local new = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
      if old then
        local hunks = {}
        local old_str = table.concat(old, "\n") .. "\n"
        local new_str = table.concat(new, "\n") .. "\n"
        for _, h in
          ipairs(vim.diff(old_str, new_str, { result_type = "indices", algorithm = "histogram" }))
        do
          local start_a, count_a, start_b, count_b = h[1], h[2], h[3], h[4]
          local removed, added = {}, {}
          for i = start_a, start_a + count_a - 1 do
            table.insert(removed, old[i])
          end
          for i = start_b, start_b + count_b - 1 do
            table.insert(added, new[i])
          end
          table.insert(hunks, { added = added, removed = removed })
        end
        if #hunks > 0 then
          log(
            "save_delta",
            vim.json.encode({
              ft = vim.bo.filetype,
              file = vim.fn.expand("%"),
              hunks = hunks,
            })
          )
        end
      end
      snapshots[ev.buf] = new
    end,
  })

  vim.api.nvim_create_autocmd("BufDelete", {
    group = augroup,
    desc = "spydog: purge snapshot",
    callback = function(ev)
      snapshots[ev.buf] = nil
    end,
  })
end

return M
