-- 창 크기 및 마크 상태 저장용 전역 변수 (세션 동안 유지)
_G.neo_tree_width = _G.neo_tree_width or 35
_G.neo_tree_marked = _G.neo_tree_marked or {}

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
        vim.notify("All marks cleared", vim.log.levels.INFO)
      end,
      delete_marked = function(state)
        local paths = vim.tbl_keys(_G.neo_tree_marked)
        if #paths == 0 then
          vim.notify("No marked files", vim.log.levels.WARN)
          return
        end
        -- 상위 디렉터리가 마크되어 있으면 하위 항목 제외
        table.sort(paths)
        local top_level = {}
        for _, path in ipairs(paths) do
          local dominated = false
          for _, other in ipairs(top_level) do
            if path:sub(1, #other + 1) == other .. "/" then
              dominated = true
              break
            end
          end
          if not dominated then
            table.insert(top_level, path)
          end
        end
        local names = vim.tbl_map(function(p)
          return "  " .. vim.fn.fnamemodify(p, ":~:.")
        end, top_level)
        local msg = string.format("Delete %d marked items?\n\n%s\n", #top_level, table.concat(names, "\n"))
        local choice = vim.fn.confirm(msg, "&Yes\n&No", 2)
        if choice == 1 then
          for _, path in ipairs(top_level) do
            vim.fn.delete(path, "rf")
          end
          _G.neo_tree_marked = {}
          require("neo-tree.sources.manager").refresh(state.name)
          vim.notify(string.format("Deleted %d items", #top_level), vim.log.levels.INFO)
        end
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
          "PATH",
          "HOME",
          "CWD",
          "FILE",
        }
        options = vim.tbl_filter(function(key)
          return vals[key] and vals[key] ~= ""
        end, options)

        vim.ui.select(options, {
          prompt = "Copy file path",
          format_item = function(item)
            return string.format("%-4s → %s", item, vals[item])
          end,
        }, function(choice)
          if choice then
            vim.fn.setreg("+", vals[choice])
            vim.notify("Copied: " .. vals[choice], vim.log.levels.INFO)
          end
        end)
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
