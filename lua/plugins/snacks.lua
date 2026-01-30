return {
  "folke/snacks.nvim",
  enabled = false,
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = " ", key = "e", desc = "Explorer", action = "<leader>e" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
        { section = "startup" },
      },
    },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    picker = {
      enabled = true,
      sources = {
        files = {
          hidden = true,
          ignored = true,
        },
        explorer = {
          hidden = true,
          ignored = true,
          actions = {
            copy_file_path = {
              action = function(_, item)
                if not item then
                  return
                end

                local vals = {
                  ["PATH"] = item.file,
                  ["PATH (CWD)"] = vim.fn.fnamemodify(item.file, ":."),
                  ["PATH (HOME)"] = vim.fn.fnamemodify(item.file, ":~"),
                  ["FILENAME"] = vim.fn.fnamemodify(item.file, ":t"),
                  ["BASENAME"] = vim.fn.fnamemodify(item.file, ":t:r"),
                  ["EXTENSION"] = vim.fn.fnamemodify(item.file, ":t:e"),
                  -- ["URI"] = vim.uri_from_fname(item.file),
                }

                local options = vim.tbl_filter(function(val)
                  return vals[val] ~= ""
                end, vim.tbl_keys(vals))
                if vim.tbl_isempty(options) then
                  vim.notify("No values to copy", vim.log.levels.WARN)
                  return
                end

                local order = {
                  "PATH",
                  "PATH (CWD)",
                  "PATH (HOME)",
                  "FILENAME",
                  "BASENAME",
                  "EXTENSION",
                  "URI",
                }

                local order_map = {}
                for i, it in ipairs(order) do
                  order_map[it] = i
                end

                table.sort(options, function(a, b)
                  return (order_map[a] or 100) < (order_map[b] or 100)
                end)

                vim.ui.select(options, {
                  prompt = "Choose to copy to clipboard:",
                  format_item = function(list_item)
                    return ("%s: %s"):format(list_item, vals[list_item])
                  end,
                }, function(choice)
                  local result = vals[choice]
                  if result then
                    vim.fn.setreg("+", result)
                    Snacks.notify.info("Yanked `" .. result .. "`")
                  end
                end)
              end,
            },
          },
          win = {
            list = {
              keys = {
                ["Y"] = "copy_file_path",
              },
            },
          },
        },
      },
      layout = {
        auto_hide = { "input" },
      },
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    styles = {
      notification_history = {
        wo = { wrap = true },
      },
    },
  },
	-- stylua: ignore
  keys = {
    -- Top Pickers & Explorer
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "Snacks: Smart Find Files" },
    { "<leader>,", function() Snacks.picker.buffers() end, desc = "Snacks: Buffers" },
    { "<leader>/", function() Snacks.picker.grep() end, desc = "Snacks: Grep" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Snacks: Command History" },
    { "<leader>n", function() Snacks.picker.notifications() end, desc = "Snacks: Notification History" },
    { "<leader>e", function() Snacks.explorer() end, desc = "Snacks: File Explorer" },
    -- find
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Snacks: Buffers" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Snacks: Find Config File" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Snacks: Find Files" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Snacks: Find Git Files" },
    { "<leader>fp", function() Snacks.picker.projects() end, desc = "Snacks: Projects" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Snacks: Recent" },
    -- git
    { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Snacks: Git Branches" },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Snacks: Git Log" },
    { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Snacks: Git Log Line" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Snacks: Git Status" },
    { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Snacks: Git Stash" },
    { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Snacks: Git Diff (Hunks)" },
    { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Snacks: Git Log File" },
    -- Grep
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "Snacks: Buffer Lines" },
    { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Snacks: Grep Open Buffers" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Snacks: Grep" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Snacks: Visual selection or word", mode = { "n", "x" } },
    -- search
    { '<leader>s"', function() Snacks.picker.registers() end, desc = "Snacks: Registers" },
    { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Snacks: Search History" },
    { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Snacks: Autocmds" },
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "Snacks: Buffer Lines" },
    { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Snacks: Command History" },
    { "<leader>sC", function() Snacks.picker.commands() end, desc = "Snacks: Commands" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Snacks: Diagnostics" },
    { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Snacks: Buffer Diagnostics" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Snacks: Help Pages" },
    { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Snacks: Highlights" },
    { "<leader>si", function() Snacks.picker.icons() end, desc = "Snacks: Icons" },
    { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Snacks: Jumps" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Snacks: Keymaps" },
    { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Snacks: Location List" },
    { "<leader>sm", function() Snacks.picker.marks() end, desc = "Snacks: Marks" },
    { "<leader>sM", function() Snacks.picker.man() end, desc = "Snacks: Man Pages" },
    { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Snacks: Search for Plugin Spec" },
    { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Snacks: Quickfix List" },
    { "<leader>sR", function() Snacks.picker.resume() end, desc = "Snacks: Resume" },
    { "<leader>su", function() Snacks.picker.undo() end, desc = "Snacks: Undo History" },
    { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Snacks: Colorschemes" },
    -- LSP
    -- { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Snacks: Goto Definition" },
    -- { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Snacks: Goto Declaration" },
    -- { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "Snacks: References" },
    -- { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Snacks: Goto Implementation" },
    -- { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Snacks: Goto T[y]pe Definition" },
    -- { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "Snacks: LSP Symbols" },
    -- { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Snacks: LSP Workspace Symbols" },
    -- Other
    { "<leader>td", function() Snacks.dashboard() end, desc = "Snacks: Open dashboard" },
    { "<leader>z",  function() Snacks.zen() end, desc = "Snacks: Toggle Zen Mode" },
    { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Snacks: Toggle Zoom" },
    { "<leader>.",  function() Snacks.scratch() end, desc = "Snacks: Toggle Scratch Buffer" },
    { "<leader>S",  function() Snacks.scratch.select() end, desc = "Snacks: Select Scratch Buffer" },
    { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Snacks: Notification History" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Snacks: Delete Buffer" },
    { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
    -- { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Snacks: Rename File" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Snacks: Git Browse", mode = { "n", "v" } },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Snacks: Lazygit" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Snacks: Dismiss All Notifications" },
    { "<leader>tf", function()
      Snacks.terminal(
        nil, {
          env = { NVIM_TERMINAL_FLOAT = "true" },
          win = { position = "float", border = "rounded" }
        }
      )
      end, desc = "Terminal (Float)" },
    { "<C-t>", function()
      Snacks.terminal(
        nil, {
          env = { NVIM_TERMINAL_FLOAT = "true" },
          win = { position = "float", border = "rounded" }
        }
      )
      end, desc = "Terminal (Float)" },
    { "<leader>tF", function()
      Snacks.terminal(
        nil, {
          env = { NVIM_TERMINAL_FLOAT = "true" },
          win = { position = "float", border = "rounded" }, cwd = vim.fn.getcwd()
        }
      )
      end, desc = "Terminal (Float, cwd)" },
    { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Snacks: Next Reference", mode = { "n", "t" } },
    { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Snacks: Prev Reference", mode = { "n", "t" } },
    {
      "<leader>N",
      desc = "Snacks: Neovim News",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end,
    }
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle
          .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
      end,
    })
  end,
}
