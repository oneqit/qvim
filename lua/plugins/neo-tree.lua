-- 창 크기 저장용 전역 변수 (세션 동안 유지)
_G.neo_tree_width = _G.neo_tree_width or 35

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1 then
          vim.cmd("Neotree show")
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
    commands = {
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
        visible = true,
        hide_dotfiles = true,
        hide_gitignored = true,
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
        ["["] = function()
          _G.neo_tree_width = math.max(20, _G.neo_tree_width - 5)
          vim.cmd("vertical resize " .. _G.neo_tree_width)
        end,
        ["]"] = function()
          _G.neo_tree_width = _G.neo_tree_width + 5
          vim.cmd("vertical resize " .. _G.neo_tree_width)
        end,
        ["="] = function()
          _G.neo_tree_width = 35
          vim.cmd("vertical resize 35")
        end,
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
