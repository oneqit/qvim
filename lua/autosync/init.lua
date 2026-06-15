-- autosync: event-driven git pull/commit/push for configured directories.
--
-- Notion-like behavior, no polling:
--   * Arrival (VimEnter/FocusGained) -> pull latest, then :checktime to reload.
--   * After save (BufWritePost)       -> debounced commit & push.
--   * On exit (VimLeavePre)           -> synchronous flush of pending saves.
--
-- Each trigger just runs sync.sh <dir>, which pulls, commits if dirty, and
-- pushes if ahead. Only buffers under a configured dir trigger anything.
--
-- Setup:
--   require("autosync").setup({
--     dirs = { "~/code/oneqit/daily-log" },
--     debounce_ms = 5000,
--   })

local M = {}

local uv = vim.uv or vim.loop

-- sync.sh lives next to this file.
local function script_path()
  local src = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(src, ":h") .. "/sync.sh"
end

local SYNC = script_path()

local cfg = { dirs = {}, debounce_ms = 5000 }
local timers = {} -- dir -> uv_timer (pending debounce)
local running = {} -- dir -> bool (in-flight guard)
local rerun = {} -- dir -> bool (a sync was requested while one was running)

-- Return the configured dir containing `path`, or nil.
local function dir_for(path)
  if not path or path == "" then
    return nil
  end
  local full = vim.fn.fnamemodify(path, ":p"):gsub("/$", "")
  for _, d in ipairs(cfg.dirs) do
    if full == d or full:sub(1, #d + 1) == d .. "/" then
      return d
    end
  end
  return nil
end

local function run_async(dir)
  if running[dir] then
    rerun[dir] = true
    return
  end
  running[dir] = true
  vim.system({ "bash", SYNC, dir }, { text = true }, function(res)
    running[dir] = false
    vim.schedule(function()
      if res.code ~= 0 then
        local err = (res.stderr or ""):gsub("%s+$", "")
        vim.notify(("autosync: %s failed (%d)\n%s"):format(dir, res.code, err), vim.log.levels.WARN)
      else
        vim.cmd("silent! checktime")
      end
      if rerun[dir] then
        rerun[dir] = false
        run_async(dir)
      end
    end)
  end)
end

local function debounce(dir)
  local t = timers[dir]
  if t then
    t:stop()
    t:close()
  end
  t = uv.new_timer()
  timers[dir] = t
  t:start(cfg.debounce_ms, 0, function()
    t:stop()
    t:close()
    timers[dir] = nil
    vim.schedule(function()
      run_async(dir)
    end)
  end)
end

function M.setup(opts)
  opts = opts or {}
  cfg.debounce_ms = opts.debounce_ms or cfg.debounce_ms
  cfg.dirs = {}
  for _, d in ipairs(opts.dirs or {}) do
    local abs = vim.fn.fnamemodify(vim.fn.expand(d), ":p"):gsub("/$", "")
    table.insert(cfg.dirs, abs)
  end
  if #cfg.dirs == 0 then
    return
  end

  local grp = vim.api.nvim_create_augroup("AutoSync", { clear = true })

  -- Arrival: pull latest before editing.
  vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
    group = grp,
    callback = function()
      local dir = dir_for(vim.api.nvim_buf_get_name(0))
      if dir then
        run_async(dir)
      end
    end,
  })

  -- After edit: debounced commit & push.
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = grp,
    callback = function(args)
      local dir = dir_for(vim.api.nvim_buf_get_name(args.buf))
      if dir then
        debounce(dir)
      end
    end,
  })

  -- On exit: flush any pending (recently-saved-but-not-yet-pushed) dirs
  -- synchronously so nothing is lost if we quit inside the debounce window.
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = grp,
    callback = function()
      for dir, t in pairs(timers) do
        t:stop()
        t:close()
        timers[dir] = nil
        vim.system({ "bash", SYNC, dir }, { text = true }):wait()
      end
    end,
  })
end

return M
