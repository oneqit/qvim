local M = {}

local defaults = {
  auto_open = true,
  auto_open_events = { "BufReadPost", "BufEnter" },
  auto_open_patterns = {
    "*.png",
    "*.jpg",
    "*.jpeg",
    "*.gif",
    "*.webp",
    "*.bmp",
    "*.tif",
    "*.tiff",
    "*.avif",
    "*.svg",
  },
  check_extension = true,
  keymaps = true,
  window = {
    border = "rounded",
    width_ratio = 0.85,
    height_ratio = 0.85,
    min_width = 40,
    min_height = 12,
    max_width = 180,
    max_height = 80,
    title_prefix = "Chafa: ",
  },
  chafa = {
    bin = "chafa",
    colors = "full",
    symbols = "vhalf+block+space",
    work = 5,
    fg_only = false,
    animate_gif = true,
    extra_args = {},
  },
}

local image_extensions = {
  avif = true,
  bmp = true,
  gif = true,
  jpeg = true,
  jpg = true,
  png = true,
  svg = true,
  tif = true,
  tiff = true,
  webp = true,
}

local state = {
  opts = nil,
  win = nil,
  buf = nil,
  job = nil,
  stopping_jobs = {},
  path = nil,
  suppressed_path = nil,
  group = vim.api.nvim_create_augroup("ChafaViewer", { clear = true }),
}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO)
end

local function is_image_path(path)
  local ext = vim.fn.fnamemodify(path, ":e"):lower()
  return image_extensions[ext] == true
end

local function is_animated_path(path)
  local ext = vim.fn.fnamemodify(path, ":e"):lower()
  return ext == "gif"
end

local function resolve_target_path(input)
  local candidates = {}
  if input and input ~= "" then
    table.insert(candidates, input)
  end

  local current_buf = vim.api.nvim_buf_get_name(0)
  if current_buf ~= "" then
    table.insert(candidates, current_buf)
  end

  local under_cursor = vim.fn.expand("<cfile>")
  if under_cursor and under_cursor ~= "" then
    table.insert(candidates, under_cursor)
  end

  for _, candidate in ipairs(candidates) do
    local absolute = vim.fn.fnamemodify(vim.fn.expand(candidate), ":p")
    if absolute ~= "" and vim.fn.filereadable(absolute) == 1 then
      return absolute
    end
  end

  return nil
end

local function stop_active_job()
  if state.job and state.job > 0 then
    state.stopping_jobs[state.job] = true
    pcall(vim.fn.jobstop, state.job)
  end
  state.job = nil
end

local function calculate_window_size()
  local opts = state.opts.window
  local available_cols = vim.o.columns
  local available_rows = math.max(6, vim.o.lines - vim.o.cmdheight - 2)

  local max_width = math.max(20, math.min(opts.max_width, available_cols - 4))
  local max_height = math.max(6, math.min(opts.max_height, available_rows - 2))
  local min_width = math.min(opts.min_width, max_width)
  local min_height = math.min(opts.min_height, max_height)

  local width = math.floor(available_cols * opts.width_ratio)
  local height = math.floor(available_rows * opts.height_ratio)
  width = math.max(min_width, math.min(width, max_width))
  height = math.max(min_height, math.min(height, max_height))

  return width, height
end

local function win_config(title)
  local width, height = calculate_window_size()
  local row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1)
  local col = math.max(0, math.floor((vim.o.columns - width) / 2))

  return {
    relative = "editor",
    style = "minimal",
    border = state.opts.window.border,
    width = width,
    height = height,
    row = row,
    col = col,
    title = title,
    title_pos = "center",
  }, width, height
end

local function set_viewer_window_options(win)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].statuscolumn = ""
  vim.wo[win].cursorline = false
end

local function on_viewer_win_closed(win_id)
  if state.win == win_id then
    state.suppressed_path = state.path
    stop_active_job()
    state.win = nil
    state.buf = nil
  end
end

local function ensure_window(title)
  local config, width, height = win_config(title)
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_set_config(state.win, config)
  else
    local buf = vim.api.nvim_create_buf(false, true)
    state.win = vim.api.nvim_open_win(buf, true, config)
    state.buf = buf
    local win_id = state.win
    vim.api.nvim_create_autocmd("WinClosed", {
      group = state.group,
      once = true,
      pattern = tostring(win_id),
      callback = function()
        on_viewer_win_closed(win_id)
      end,
    })
  end

  set_viewer_window_options(state.win)
  return width, height
end

local function set_buffer_keymaps(buf)
  local map_opts = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set({ "n", "t" }, "q", function()
    M.close()
  end, vim.tbl_extend("force", map_opts, { desc = "Chafa: Close viewer" }))
  vim.keymap.set({ "n", "t" }, "r", function()
    M.refresh()
  end, vim.tbl_extend("force", map_opts, { desc = "Chafa: Refresh image" }))
end

local function replace_terminal_buffer()
  local new_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[new_buf].bufhidden = "wipe"
  vim.bo[new_buf].swapfile = false
  vim.bo[new_buf].filetype = "chafa-viewer"
  set_buffer_keymaps(new_buf)
  vim.api.nvim_win_set_buf(state.win, new_buf)

  if state.buf and vim.api.nvim_buf_is_valid(state.buf) and state.buf ~= new_buf then
    pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
  end

  state.buf = new_buf
  return new_buf
end

local function build_chafa_command(path, width, height)
  local chafa = state.opts.chafa
  local animate = chafa.animate_gif and is_animated_path(path)
  local cmd = {
    chafa.bin,
    "--format=symbols",
    animate and "--animate=on" or "--animate=off",
    "--clear",
    "--size=" .. width .. "x" .. height,
    "--colors=" .. chafa.colors,
    "--work=" .. tostring(chafa.work),
  }

  if chafa.symbols and chafa.symbols ~= "" then
    table.insert(cmd, "--symbols=" .. chafa.symbols)
  end

  if chafa.fg_only then
    table.insert(cmd, "--fg-only")
  end

  for _, arg in ipairs(chafa.extra_args or {}) do
    table.insert(cmd, arg)
  end

  table.insert(cmd, path)
  return cmd
end

function M.view(path_arg, view_opts)
  local focus_viewer = true
  if type(view_opts) == "table" and view_opts.focus_viewer ~= nil then
    focus_viewer = view_opts.focus_viewer
  end

  if vim.fn.executable(state.opts.chafa.bin) ~= 1 then
    notify("chafa executable not found: " .. state.opts.chafa.bin, vim.log.levels.ERROR)
    return
  end

  local path = resolve_target_path(path_arg)
  if not path then
    notify("No readable image file found. Pass a path to :ChafaView.", vim.log.levels.WARN)
    return
  end

  if state.suppressed_path == path then
    state.suppressed_path = nil
  end

  if state.opts.check_extension and not is_image_path(path) then
    notify("Not an image extension: " .. path, vim.log.levels.WARN)
    return
  end

  local title = state.opts.window.title_prefix .. vim.fn.fnamemodify(path, ":t")
  local window_width, window_height = ensure_window(title)
  replace_terminal_buffer()
  stop_active_job()

  local render_width = math.max(4, window_width - 2)
  local render_height = math.max(2, window_height - 2)
  local cmd = build_chafa_command(path, render_width, render_height)

  state.path = path
  if focus_viewer then
    vim.api.nvim_set_current_win(state.win)
  end
  vim.api.nvim_win_call(state.win, function()
    state.job = vim.fn.termopen(cmd, {
      on_exit = function(job_id, code)
        if state.job == job_id then
          state.job = nil
        end
        if state.stopping_jobs[job_id] then
          state.stopping_jobs[job_id] = nil
          return
        end
        if code ~= 0 then
          vim.schedule(function()
            notify("chafa exited with code " .. code, vim.log.levels.ERROR)
          end)
        end
      end,
    })
    vim.cmd("stopinsert")
  end)
end

function M.refresh()
  if not state.path then
    notify("No active image to refresh.", vim.log.levels.WARN)
    return
  end
  M.view(state.path)
end

function M.close()
  state.suppressed_path = state.path
  stop_active_job()

  if state.win and vim.api.nvim_win_is_valid(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end

  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
  end

  state.win = nil
  state.buf = nil
end

local function create_commands()
  pcall(vim.api.nvim_del_user_command, "ChafaView")
  pcall(vim.api.nvim_del_user_command, "ChafaRefresh")
  pcall(vim.api.nvim_del_user_command, "ChafaClose")

  vim.api.nvim_create_user_command("ChafaView", function(opts)
    local target = opts.args ~= "" and opts.args or nil
    M.view(target)
  end, {
    nargs = "?",
    complete = "file",
    desc = "View image using chafa in a floating window",
  })

  vim.api.nvim_create_user_command("ChafaRefresh", function()
    M.refresh()
  end, { desc = "Refresh current chafa image view" })

  vim.api.nvim_create_user_command("ChafaClose", function()
    M.close()
  end, { desc = "Close chafa image view" })
end

local function create_keymaps()
  vim.keymap.set("n", "<leader>iv", function()
    M.view()
  end, { desc = "Image: View with chafa" })

  vim.keymap.set("n", "<leader>iV", function()
    local target = vim.fn.input("Image path: ", "", "file")
    if target ~= "" then
      M.view(target)
    end
  end, { desc = "Image: View path with chafa" })

  vim.keymap.set("n", "<leader>ir", function()
    M.refresh()
  end, { desc = "Image: Refresh chafa view" })

  vim.keymap.set("n", "<leader>ic", function()
    M.close()
  end, { desc = "Image: Close chafa view" })
end

local function create_auto_open_autocmd()
  if not state.opts.auto_open then
    return
  end

  vim.api.nvim_create_autocmd(state.opts.auto_open_events, {
    group = state.group,
    pattern = state.opts.auto_open_patterns,
    callback = function(args)
      if vim.bo[args.buf].buftype ~= "" then
        return
      end
      local file = vim.api.nvim_buf_get_name(args.buf)
      if file == "" then
        return
      end
      if state.suppressed_path == file then
        return
      end
      if state.win and vim.api.nvim_win_is_valid(state.win) and state.path == file then
        return
      end
      vim.schedule(function()
        M.view(file, { focus_viewer = false })
      end)
    end,
  })

  vim.api.nvim_create_autocmd("BufLeave", {
    group = state.group,
    pattern = state.opts.auto_open_patterns,
    callback = function(args)
      local file = vim.api.nvim_buf_get_name(args.buf)
      if file ~= "" and state.suppressed_path == file then
        state.suppressed_path = nil
      end
    end,
  })
end

function M.setup(opts)
  state.opts = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  state.group = vim.api.nvim_create_augroup("ChafaViewer", { clear = true })

  create_commands()
  if state.opts.keymaps then
    create_keymaps()
  end
  create_auto_open_autocmd()
end

return M
