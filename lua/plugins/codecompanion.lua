return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("codecompanion").setup({
      adapters = {},
      strategies = {
        chat = {
          adapter = "copilot",
        },
        inline = {
          adapter = "copilot",
        },
      },
      display = {
        chat = {
          -- start_in_insert_mode = true,
          window = {
            layout = "float",
            width = 0.8,
            height = 0.8,
          },
        },
      },
      opts = {
        system_prompt = function()
          return ""
        end,
        log_level = "DEBUG", -- or "TRACE"
      },
    })
    vim.keymap.set(
      { "n", "v", "i" },
      "<C-q>",
      "<cmd>CodeCompanionChat Toggle<cr>",
      { noremap = true, silent = true, desc = "CodeCompanion: Toggle code companion chat" }
    )
    -- vim.keymap.set(
    --   { "n", "v" },
    --   "<leader>cca",
    --   "<cmd>CodeCompanionActions<cr>",
    --   { noremap = true, silent = true, desc = "CodeCompanion: [c]ode [c]ompanion [a]ctions" }
    -- )
    -- vim.keymap.set(
    --   { "n", "v" },
    --   "<leader>cct",
    --   "<cmd>CodeCompanionChat Toggle<cr>",
    --   { noremap = true, silent = true, desc = "CodeCompanion: [c]ode [c]ompanion [t]oggle" }
    -- )
    -- vim.keymap.set(
    --   "v",
    --   "<leader>ccy",
    --   "<cmd>CodeCompanionChat Add<cr>",
    --   { noremap = true, silent = true, desc = "CodeCompanion: [c]ode [c]ompanion cop[y] to chat" }
    -- )

    -- CodeCompanion save/load
    -- local cwd = vim.fn.getcwd()
    -- local project_basename = vim.fn.fnamemodify(cwd, ":t")
    -- local chat_id = project_basename .. "_" .. get_hash(cwd) .. "_" .. os.date("%Y%m%d")
    --
    -- local chat_path = Path:new(vim.env.HOME .. "/.codecompanionchat/" .. chat_id)
    -- if not chat_path:exists() then
    --   chat_path:mkdir({ parents = true })
    -- end

    local chat_root = vim.fn.stdpath('data') .. '/codecompanionchat_history'
    local Path = require("plenary.path")

    vim.api.nvim_create_user_command("CodeCompanionSave", function()
      local codecompanion = require("codecompanion")
      local success, chat = pcall(function()
        return codecompanion.buf_get_chat(0)
      end)
      if not success or chat == nil then
        vim.notify("CodeCompanionSave should only be called from CodeCompanion chat buffers", "error")
        return
      end

      local chat_dir = chat_root .. "/" .. os.date("%Y%m%d")
      local cwd = vim.fn.getcwd()
      local cwd_basename = vim.fn.fnamemodify(cwd, ":t")
      local chat_file = cwd_basename .. "_" .. vim.fn.sha256(cwd):sub(1, 8) .. ".md"
      local chat_file_abspath = chat_dir .. "/" .. chat_file

      local save_dir = Path:new(chat_dir)
      if not save_dir:exists() then
        save_dir:mkdir({ parents = true })
      end

      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      Path:new(chat_dir, chat_file):write(table.concat(lines, "\n"), "w")
      vim.notify("Saved at:\n  " .. chat_file_abspath, "info")
    end, {})

    vim.api.nvim_create_user_command("CodeCompanionLoad", function()
      local t_builtin = require("telescope.builtin")
      local t_actions = require("telescope.actions")
      local t_action_state = require("telescope.actions.state")

      local function start_picker()
        t_builtin.find_files({
          prompt_title = "Saved CodeCompanion Chats | <C-d>: Delete",
          cwd = Path:new(chat_root):absolute(),
          attach_mappings = function(_, map)
            map({ "i", "n" }, "<C-d>", function(prompt_bufnr)
              local selection = t_action_state.get_selected_entry()
              local file = selection.path or selection.filename
              os.remove(file)
              vim.notify("Deleted:\n  " .. file)
              t_actions.close(prompt_bufnr)
              start_picker()
            end)
            return true
          end,
        })
      end
      start_picker()
    end, {})
  end,
}
