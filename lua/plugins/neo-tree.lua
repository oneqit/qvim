-- 창 크기 및 마크 상태 저장용 전역 변수 (세션 동안 유지)
_G.neo_tree_width = _G.neo_tree_width or 35
_G.neo_tree_marked = _G.neo_tree_marked or {}

-- 주어진 경로(파일 또는 디렉터리)들에 영향받는 열린 버퍼 목록
local function affected_buffers(paths)
  local hits = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" then
        for _, p in ipairs(paths) do
          if name == p or name:sub(1, #p + 1) == p .. "/" then
            table.insert(hits, { buf = buf, name = name })
            break
          end
        end
      end
    end
  end
  return hits
end

local function close_buffers(bufs)
  local ok_snacks, Snacks = pcall(function()
    return Snacks
  end)
  for _, b in ipairs(bufs) do
    if vim.api.nvim_buf_is_valid(b.buf) then
      if ok_snacks and Snacks and Snacks.bufdelete then
        pcall(Snacks.bufdelete, { buf = b.buf, force = true })
      else
        pcall(vim.api.nvim_buf_delete, b.buf, { force = true })
      end
    end
  end
end

-- 마크된 경로들에서 top-level만 추리기 (상위 디렉터리가 마크된 경우 하위 제외)
local function top_level_marked()
  local paths = vim.tbl_keys(_G.neo_tree_marked)
  table.sort(paths)
  local top = {}
  for _, path in ipairs(paths) do
    local dominated = false
    for _, other in ipairs(top) do
      if path:sub(1, #other + 1) == other .. "/" then
        dominated = true
        break
      end
    end
    if not dominated then
      table.insert(top, path)
    end
  end
  return top
end

-- confirm 메시지에 영향받는 버퍼 정보 추가, force 필요 여부 반환
local function build_buffer_warning(bufs)
  if #bufs == 0 then
    return "", false
  end
  local lines = { "", string.format("⚠ %d open buffer(s) will be closed:", #bufs) }
  local has_modified = false
  for _, b in ipairs(bufs) do
    local modified = vim.api.nvim_get_option_value("modified", { buf = b.buf })
    local marker = modified and " [+]" or ""
    if modified then
      has_modified = true
    end
    table.insert(lines, "  " .. vim.fn.fnamemodify(b.name, ":~:.") .. marker)
  end
  if has_modified then
    table.insert(lines, "")
    table.insert(lines, "⚠ Some buffers have unsaved changes ([+]). Force close?")
  end
  return table.concat(lines, "\n"), has_modified
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  config = function(_, opts)
    -- 마크 표시 커스텀 컴포넌트 등록
    local cc = require("neo-tree.sources.common.components")
    cc.mark_indicator = function(_, node, _)
      if _G.neo_tree_marked[node:get_id()] then
        return { text = "● ", highlight = "DiagnosticWarn" }
      end
      return { text = "" }
    end
    require("neo-tree").setup(opts)
  end,
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        local arg = vim.fn.argv(0)
        if arg and vim.fn.isdirectory(arg) == 1 then
          vim.cmd.cd(arg)
          vim.cmd("bdelete")
          vim.cmd("Neotree show")
        elseif vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1 then
          vim.cmd("Neotree show")
        end
      end,
    })
    -- 종료 시 neo-tree를 먼저 닫아서 close_if_last_window 경고 방지
    vim.api.nvim_create_autocmd("QuitPre", {
      callback = function()
        -- 현재 윈도우가 neo-tree이면 개입하지 않음 (qa 등이 정상 동작하도록)
        local cur_buf = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(0))
        if cur_buf:match("neo%-tree") then
          return
        end
        local tree_wins = {}
        local floating_wins = {}
        local wins = vim.api.nvim_list_wins()
        for _, w in ipairs(wins) do
          local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
          if bufname:match("neo%-tree") then
            table.insert(tree_wins, w)
          end
          if vim.api.nvim_win_get_config(w).relative ~= "" then
            table.insert(floating_wins, w)
          end
        end
        if #wins - #floating_wins - #tree_wins == 1 then
          for _, w in ipairs(tree_wins) do
            vim.api.nvim_win_close(w, true)
          end
        end
      end,
    })
    -- Neovim에 포커스 돌아올 때 neo-tree git status 갱신
    vim.api.nvim_create_autocmd("FocusGained", {
      callback = function()
        local ok, manager = pcall(require, "neo-tree.sources.manager")
        if ok then
          manager.refresh("filesystem")
        end
      end,
    })
    -- 열릴 때 저장된 크기로 복원
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "neo-tree",
      callback = function()
        vim.defer_fn(function()
          vim.cmd("vertical resize " .. _G.neo_tree_width)
        end, 10)
      end,
    })
  end,
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Neo-tree: Toggle" },
    { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Neo-tree: Reveal current file" },
  },
  opts = {
    close_if_last_window = true,
    sources = { "filesystem", "git_status" },
    source_selector = {
      sources = {
        { source = "filesystem" },
        { source = "git_status" },
      },
    },
    renderers = {
      directory = {
        { "indent" },
        { "mark_indicator" },
        { "icon" },
        { "current_filter" },
        { "container", content = {
          { "name", zindex = 10 },
          { "clipboard", zindex = 10 },
          { "diagnostics", errors_only = true, zindex = 20, align = "right", hide_when_expanded = true },
          { "git_status", zindex = 10, align = "right", hide_when_expanded = true },
        } },
      },
      file = {
        { "indent" },
        { "mark_indicator" },
        { "icon" },
        { "diagnostics" },
        { "name", use_git_status_colors = true },
        { "modified" },
        { "git_status" },
      },
    },
    commands = {
      toggle_mark = function(state)
        local node = state.tree:get_node()
        if not node then
          return
        end
        local id = node:get_id()
        local marking = not _G.neo_tree_marked[id]
        _G.neo_tree_marked[id] = marking or nil
        if node.type == "directory" then
          local children = vim.fn.glob(id .. "/**", false, true)
          for _, child in ipairs(children) do
            _G.neo_tree_marked[child] = marking or nil
          end
        end
        require("neo-tree.sources.manager").refresh(state.name)
      end,
      unmark_all = function(state)
        _G.neo_tree_marked = {}
        require("neo-tree.sources.manager").refresh(state.name)
        -- vim.notify("All marks cleared", vim.log.levels.INFO)
      end,
      delete_marked = function(state)
        if vim.tbl_isempty(_G.neo_tree_marked) then
          vim.notify("No marked files", vim.log.levels.WARN)
          return
        end
        local top_level = top_level_marked()
        local names = vim.tbl_map(function(p)
          return "  " .. vim.fn.fnamemodify(p, ":~:.")
        end, top_level)
        local bufs = affected_buffers(top_level)
        local buf_warning, has_modified = build_buffer_warning(bufs)
        local msg = string.format(
          "Delete %d marked items?\n\n%s\n%s",
          #top_level,
          table.concat(names, "\n"),
          buf_warning
        )
        local prompt = has_modified and "&Yes (force)\n&No" or "&Yes\n&No"
        local choice = vim.fn.confirm(msg, prompt, 2)
        if choice == 1 then
          close_buffers(bufs)
          for _, path in ipairs(top_level) do
            vim.fn.delete(path, "rf")
          end
          _G.neo_tree_marked = {}
          require("neo-tree.sources.manager").refresh(state.name)
          vim.notify(string.format("Deleted %d items", #top_level), vim.log.levels.INFO)
        end
      end,
      move_marked = function(state)
        if vim.tbl_isempty(_G.neo_tree_marked) then
          vim.notify("No marked files", vim.log.levels.WARN)
          return
        end
        local top_level = top_level_marked()
        local node = state.tree:get_node()
        local default_dest = vim.fn.getcwd()
        if node then
          local id = node:get_id()
          default_dest = node.type == "directory" and id or vim.fn.fnamemodify(id, ":h")
        end
        vim.ui.input({
          prompt = "Move to directory: ",
          default = default_dest .. "/",
          completion = "dir",
        }, function(input)
          if not input or input == "" then
            return
          end
          local dest = vim.fn.fnamemodify(vim.fn.expand(input), ":p"):gsub("/$", "")

          -- 자기 자신 또는 하위로 이동 차단
          for _, path in ipairs(top_level) do
            if dest == path or dest:sub(1, #path + 1) == path .. "/" then
              vim.notify(
                "Cannot move into itself: " .. vim.fn.fnamemodify(path, ":~:."),
                vim.log.levels.ERROR
              )
              return
            end
          end

          -- 목적지 존재/디렉터리 검증
          if vim.fn.isdirectory(dest) == 0 then
            if vim.fn.filereadable(dest) == 1 then
              vim.notify("Destination is a file: " .. dest, vim.log.levels.ERROR)
              return
            end
            local create = vim.fn.confirm(
              "Directory does not exist:\n  " .. vim.fn.fnamemodify(dest, ":~:.") .. "\n\nCreate it?",
              "&Yes\n&No",
              1
            )
            if create ~= 1 then
              return
            end
            vim.fn.mkdir(dest, "p")
          end

          -- 이름 충돌 검사
          local conflicts = {}
          for _, path in ipairs(top_level) do
            local target = dest .. "/" .. vim.fn.fnamemodify(path, ":t")
            if vim.fn.filereadable(target) == 1 or vim.fn.isdirectory(target) == 1 then
              table.insert(conflicts, target)
            end
          end
          if #conflicts > 0 then
            local conflict_lines = vim.tbl_map(function(p)
              return "  " .. vim.fn.fnamemodify(p, ":~:.")
            end, conflicts)
            vim.notify(
              "Destination already contains:\n" .. table.concat(conflict_lines, "\n"),
              vim.log.levels.ERROR
            )
            return
          end

          local names = vim.tbl_map(function(p)
            return "  " .. vim.fn.fnamemodify(p, ":~:.")
          end, top_level)
          local bufs = affected_buffers(top_level)
          local buf_warning, has_modified = build_buffer_warning(bufs)
          local msg = string.format(
            "Move %d items to %s?\n\n%s\n%s",
            #top_level,
            vim.fn.fnamemodify(dest, ":~:."),
            table.concat(names, "\n"),
            buf_warning
          )
          local prompt = has_modified and "&Yes (force)\n&No" or "&Yes\n&No"
          local choice = vim.fn.confirm(msg, prompt, 2)
          if choice ~= 1 then
            return
          end

          close_buffers(bufs)
          local moved, failed = 0, {}
          for _, path in ipairs(top_level) do
            local result = vim.system({ "mv", path, dest .. "/" }):wait()
            if result.code == 0 then
              moved = moved + 1
            else
              table.insert(failed, vim.fn.fnamemodify(path, ":~:.") .. ": " .. (result.stderr or ""))
            end
          end
          _G.neo_tree_marked = {}
          require("neo-tree.sources.manager").refresh(state.name)
          if #failed > 0 then
            vim.notify(
              string.format("Moved %d items, %d failed:\n%s", moved, #failed, table.concat(failed, "\n")),
              vim.log.levels.WARN
            )
          else
            vim.notify(
              string.format("Moved %d items to %s", moved, vim.fn.fnamemodify(dest, ":~:.")),
              vim.log.levels.INFO
            )
          end
        end)
      end,
      copy_file_path = function(state)
        local node = state.tree:get_node()
        if not node then
          return
        end

        local filepath = node:get_id()
        local vals = {
          ["PATH"] = filepath,
          ["CWD"] = vim.fn.fnamemodify(filepath, ":."),
          ["HOME"] = vim.fn.fnamemodify(filepath, ":~"),
          ["FILE"] = vim.fn.fnamemodify(filepath, ":t"),
        }

        local options = {
          "FILE",
          "CWD",
          "HOME",
          "PATH",
        }
        options = vim.tbl_filter(function(key)
          return vals[key] and vals[key] ~= ""
        end, options)

        local NuiPopup = require("nui.popup")
        local popups = require("neo-tree.ui.popups")

        local max_val_len = 0
        for _, key in ipairs(options) do
          max_val_len = math.max(max_val_len, #vals[key])
        end
        local content_width = max_val_len + 12
        local popup_opts = popups.popup_options("Copy file path", content_width)
        popup_opts.enter = true
        popup_opts.zindex = 60
        popup_opts.size = { width = content_width, height = #options }
        popup_opts.position = { row = 2, col = 0 }

        local popup = NuiPopup(popup_opts)
        popup:mount()

        local lines = {}
        local highlights = {}
        for i, key in ipairs(options) do
          local num = string.format(" %d. ", i)
          local label = string.format("%-4s", key)
          local arrow = " → "
          local value = vals[key]
          lines[i] = num .. label .. arrow .. value
          table.insert(highlights, { line = i, col = 0, end_col = #num, hl = "Number" })
          table.insert(highlights, { line = i, col = #num, end_col = #num + #label, hl = "Type" })
          table.insert(highlights, { line = i, col = #num + #label, end_col = #num + #label + #arrow, hl = "Comment" })
          table.insert(highlights, { line = i, col = #num + #label + #arrow, end_col = #lines[i], hl = "String" })
        end

        vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
        vim.api.nvim_set_option_value("modifiable", false, { buf = popup.bufnr })
        vim.api.nvim_set_option_value("cursorline", true, { win = popup.winid })

        for _, h in ipairs(highlights) do
          vim.api.nvim_buf_add_highlight(popup.bufnr, -1, h.hl, h.line - 1, h.col, h.end_col)
        end

        local function select_item(idx)
          popup:unmount()
          local key = options[idx]
          if key then
            vim.fn.setreg("+", vals[key])
            vim.notify("Copied: " .. vals[key], vim.log.levels.INFO)
          end
        end

        local function close()
          popup:unmount()
        end

        popup:map("n", "<esc>", close)
        popup:map("n", "q", close)
        popup:map("n", "<cr>", function()
          local row = vim.api.nvim_win_get_cursor(popup.winid)[1]
          select_item(row)
        end)
        for i = 1, #options do
          popup:map("n", tostring(i), function()
            select_item(i)
          end)
        end
      end,
    },
    filesystem = {
      follow_current_file = {
        enabled = true,
      },
      use_libuv_file_watcher = true,
      filtered_items = {
        visible = false,
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = {
          ".DS_Store",
          ".git",
          ".idea",
          ".next",
          ".pytest_cache",
          ".venv",
          ".vscode",
          "__pycache__",
          "node_modules",
        },
      },
    },
    window = {
      position = "left",
      width = 35,
      auto_expand_width = false,
      mappings = {
        ["Y"] = "copy_file_path",
        ["l"] = "open",
        ["h"] = "close_node",
        ["z"] = "close_all_subnodes",
        ["Z"] = "expand_all_subnodes",
        ["<leader>z"] = "close_all_nodes",
        ["<leader>Z"] = "expand_all_nodes",
        ["<space>"] = "none",
        ["<tab>"] = "prev_source",
        ["<s-tab>"] = "next_source",
        ["<"] = function()
          _G.neo_tree_width = math.max(20, _G.neo_tree_width - 5)
          vim.cmd("vertical resize " .. _G.neo_tree_width)
        end,
        [">"] = function()
          _G.neo_tree_width = _G.neo_tree_width + 5
          vim.cmd("vertical resize " .. _G.neo_tree_width)
        end,
        ["="] = function()
          _G.neo_tree_width = 35
          vim.cmd("vertical resize 35")
        end,
        ["ga"] = "git_add_file",
        ["gu"] = "git_unstage_file",
        ["gr"] = "git_revert_file",
        ["gc"] = "git_commit",
        ["v"] = "toggle_mark",
        ["<esc>"] = "unmark_all",
        ["D"] = "delete_marked",
        ["M"] = "move_marked",
      },
    },
    default_component_configs = {
      git_status = {
        symbols = {
          added = "+",
          modified = "~",
          deleted = "x",
          renamed = "r",
          untracked = "?",
          ignored = "◌",
          unstaged = "✗",
          staged = "✓",
          conflict = "",
        },
      },
    },
  },
}
