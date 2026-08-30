--- @since 25.4.8
-- stylua: ignore
-- bookmarks.yazi — marks à la vim : `m` + <key> pour poser, `'` + <key> pour sauter.
-- Adapté de dedukun/bookmarks.yazi. La persistance (DDS) et le « dernier dossier »
-- ont été retirés volontairement : les marks restent en mémoire, propres à la session.

local SUPPORTED_KEYS = {
	{ on = "0", desc = "Libre" }, { on = "1", desc = "Libre" }, { on = "2", desc = "Libre" }, { on = "3", desc = "Libre" }, { on = "4", desc = "Libre" },
	{ on = "5", desc = "Libre" }, { on = "6", desc = "Libre" }, { on = "7", desc = "Libre" }, { on = "8", desc = "Libre" }, { on = "9", desc = "Libre" },
	{ on = "A", desc = "Libre" }, { on = "B", desc = "Libre" }, { on = "C", desc = "Libre" }, { on = "D", desc = "Libre" }, { on = "E", desc = "Libre" },
	{ on = "F", desc = "Libre" }, { on = "G", desc = "Libre" }, { on = "H", desc = "Libre" }, { on = "I", desc = "Libre" }, { on = "J", desc = "Libre" },
	{ on = "K", desc = "Libre" }, { on = "L", desc = "Libre" }, { on = "M", desc = "Libre" }, { on = "N", desc = "Libre" }, { on = "O", desc = "Libre" },
	{ on = "P", desc = "Libre" }, { on = "Q", desc = "Libre" }, { on = "R", desc = "Libre" }, { on = "S", desc = "Libre" }, { on = "T", desc = "Libre" },
	{ on = "U", desc = "Libre" }, { on = "V", desc = "Libre" }, { on = "W", desc = "Libre" }, { on = "X", desc = "Libre" }, { on = "Y", desc = "Libre" }, { on = "Z", desc = "Libre" },
	{ on = "a", desc = "Libre" }, { on = "b", desc = "Libre" }, { on = "c", desc = "Libre" }, { on = "d", desc = "Libre" }, { on = "e", desc = "Libre" },
	{ on = "f", desc = "Libre" }, { on = "g", desc = "Libre" }, { on = "h", desc = "Libre" }, { on = "i", desc = "Libre" }, { on = "j", desc = "Libre" },
	{ on = "k", desc = "Libre" }, { on = "l", desc = "Libre" }, { on = "m", desc = "Libre" }, { on = "n", desc = "Libre" }, { on = "o", desc = "Libre" },
	{ on = "p", desc = "Libre" }, { on = "q", desc = "Libre" }, { on = "r", desc = "Libre" }, { on = "s", desc = "Libre" }, { on = "t", desc = "Libre" },
	{ on = "u", desc = "Libre" }, { on = "v", desc = "Libre" }, { on = "w", desc = "Libre" }, { on = "x", desc = "Libre" }, { on = "y", desc = "Libre" }, { on = "z", desc = "Libre" },
}

local _send_notification = ya.sync(function(state, message)
  ya.notify({
    title = "Bookmarks",
    content = message,
    timeout = state.notify.timeout,
  })
end)

local _get_real_index = ya.sync(function(state, idx)
  for key, value in pairs(state.bookmarks) do
    if value.on == SUPPORTED_KEYS[idx].on then
      return key
    end
  end
  return nil
end)

local _get_bookmark_file = ya.sync(function(state)
  local folder = cx.active.current

  if state.file_pick_mode == "parent" or not folder.hovered then
    return { url = folder.cwd, is_parent = true }
  end
  return { url = folder.hovered.url, is_parent = false }
end)

local _generate_description = ya.sync(function(state, file)
  -- Dossier (ou rien sous le curseur) : on renvoie directement son url.
  if file.is_parent then
    return tostring(file.url)
  end

  -- Fichier : selon la config, parent uniquement ou chemin complet.
  if state.desc_format == "parent" then
    return tostring(file.url.parent)
  end
  return tostring(file.url)
end)

local _is_show_keys_enabled = ya.sync(function(state)
  return state.show_keys
end)

local _is_custom_desc_input_enabled = ya.sync(function(state)
  return state.custom_desc_input
end)

local get_updated_keys = ya.sync(function(state, keys)
  if state.bookmarks then
    for _, bookmarks_value in pairs(state.bookmarks) do
      for _, keys_value in pairs(keys) do
        if keys_value.on == bookmarks_value.on then
          keys_value.desc = bookmarks_value.desc
        end
      end
    end
  end
  return keys
end)

local save_bookmark = ya.sync(function(state, idx, custom_desc)
  local file = _get_bookmark_file()

  state.bookmarks = state.bookmarks or {}

  local _idx = _get_real_index(idx)
  if not _idx then
    _idx = #state.bookmarks + 1
  end

  local bookmark_desc = tostring(_generate_description(file))
  if custom_desc then
    bookmark_desc = tostring(custom_desc)
  end

  state.bookmarks[_idx] = {
    on = SUPPORTED_KEYS[idx].on,
    desc = bookmark_desc,
    path = tostring(file.url),
    is_parent = file.is_parent,
  }

  -- Tri : chiffres d'abord, puis majuscules avant minuscules, puis ordre alphabétique.
  table.sort(state.bookmarks, function(a, b)
    local key_a, key_b = a.on, b.on

    if key_a:match("%d") and not key_b:match("%d") then
      return true
    elseif key_b:match("%d") and not key_a:match("%d") then
      return false
    end

    if key_a:match("%u") and key_b:match("%l") then
      return true
    elseif key_b:match("%u") and key_a:match("%l") then
      return false
    end

    return key_a < key_b
  end)

  if state.notify and state.notify.enable then
    local message = state.notify.message.new
    message, _ = message:gsub("<key>", state.bookmarks[_idx].on)
    message, _ = message:gsub("<folder>", state.bookmarks[_idx].desc)
    _send_notification(message)
  end
end)

local all_bookmarks = ya.sync(function(state)
  local bookmarks = {}

  if state.bookmarks then
    for _, value in pairs(state.bookmarks) do
      table.insert(bookmarks, value)
    end
  end

  return bookmarks
end)

local delete_bookmark = ya.sync(function(state, idx)
  if state.notify and state.notify.enable then
    local message = state.notify.message.delete
    message, _ = message:gsub("<key>", state.bookmarks[idx].on)
    message, _ = message:gsub("<folder>", state.bookmarks[idx].desc)
    _send_notification(message)
  end

  table.remove(state.bookmarks, idx)
end)

local delete_all_bookmarks = ya.sync(function(state)
  state.bookmarks = nil

  if state.notify and state.notify.enable then
    _send_notification(state.notify.message.delete_all)
  end
end)

return {
  entry = function(_, job)
    local action = job.args[1]
    if not action then
      return
    end

    if action == "save" then
      if _is_show_keys_enabled() then
        SUPPORTED_KEYS = get_updated_keys(SUPPORTED_KEYS)
      end
      local key = ya.which({ cands = SUPPORTED_KEYS, silent = not _is_show_keys_enabled() })
      if key then
        if _is_custom_desc_input_enabled() then
          local value, event = ya.input({
            title = "Description du mark :",
            position = { "top-center", y = 3, w = 60 },
            value = tostring(_get_bookmark_file().url),
          })
          if event ~= 1 then
            return
          end

          save_bookmark(key, value)
          return
        end
        save_bookmark(key)
      end
      return
    end

    if action == "delete_all" then
      return delete_all_bookmarks()
    end

    local bookmarks = all_bookmarks()
    local selected = #bookmarks > 0 and ya.which({ cands = bookmarks })
    if not selected then
      return
    end

    if action == "jump" then
      if bookmarks[selected].is_parent then
        ya.emit("cd", { bookmarks[selected].path })
      else
        ya.emit("reveal", { bookmarks[selected].path })
      end
    elseif action == "delete" then
      delete_bookmark(selected)
    end
  end,

  setup = function(state, args)
    -- Valeurs par défaut : marks éphémères, aucune persistance.
    state.desc_format = "full"
    state.file_pick_mode = "hover"
    state.show_keys = false
    state.custom_desc_input = false
    state.notify = {
      enable = false,
      timeout = 1,
      message = {
        new = "Mark '<key>' -> '<folder>'",
        delete = "Mark '<key>' supprimé",
        delete_all = "Tous les marks supprimés",
      },
    }

    if not args then
      return
    end

    if args.desc_format == "parent" then
      state.desc_format = "parent"
    end

    if args.file_pick_mode == "parent" then
      state.file_pick_mode = "parent"
    end

    if type(args.show_keys) == "boolean" then
      state.show_keys = args.show_keys
    end

    if type(args.custom_desc_input) == "boolean" then
      state.custom_desc_input = args.custom_desc_input
    end

    if type(args.notify) == "table" then
      if type(args.notify.enable) == "boolean" then
        state.notify.enable = args.notify.enable
      end
      if type(args.notify.timeout) == "number" then
        state.notify.timeout = args.notify.timeout
      end
      if type(args.notify.message) == "table" then
        if type(args.notify.message.new) == "string" then
          state.notify.message.new = args.notify.message.new
        end
        if type(args.notify.message.delete) == "string" then
          state.notify.message.delete = args.notify.message.delete
        end
        if type(args.notify.message.delete_all) == "string" then
          state.notify.message.delete_all = args.notify.message.delete_all
        end
      end
    end
  end,
}
