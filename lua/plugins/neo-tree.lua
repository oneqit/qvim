return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
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
      auto_expand_width = true,
      mappings = {
        ["Y"] = "copy_file_path",
        ["l"] = "open",
        ["h"] = "close_node",
        ["z"] = "expand_all_subnodes",
        ["Z"] = "close_all_subnodes",
        ["<leader>z"] = "expand_all_nodes",
        ["<leader>Z"] = "close_all_nodes",
        ["<space>"] = "none",
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
