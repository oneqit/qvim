return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
    { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
  },
  build = "make tiktoken", -- Only on MacOS or Linux
  keys = {
    -- { "<leader>cc", ":CopilotChat<CR>", desc = "CopilotChat: Open chat with optional input" },
    -- { "<leader>co", ":CopilotChatOpen<CR>", desc = "CopilotChat: Open chat window" },
    { "<leader>cx", ":CopilotChatClose<CR>", desc = "CopilotChat: Close chat window" },
    { "<leader>cc", ":CopilotChatToggle<CR>", desc = "CopilotChat: Toggle chat window" },
    { "<C-a>", ":CopilotChatToggle<CR>", mode = { "n", "i", "v" }, desc = "CopilotChat: Toggle chat window" },
    { "<C-c>", ":CopilotChatStop<CR>", desc = "CopilotChat: Stop current output" },
    { "<leader>cR", ":CopilotChatReset<CR>", desc = "CopilotChat: Reset chat window" },
    -- { "<leader>cS", ":CopilotChatSave<CR>", desc = "CopilotChat: Save chat history" },
    -- { "<leader>cL", ":CopilotChatLoad<CR>", desc = "CopilotChat: Load chat history" },
    { "<leader>cP", ":CopilotChatPrompts<CR>", desc = "CopilotChat: View/select prompt templates" },
    { "<leader>cM", ":CopilotChatModels<CR>", desc = "CopilotChat: View/select available models" },
    { "<leader>cA", ":CopilotChatAgents<CR>", desc = "CopilotChat: View/select available agents" },
  },
  config = function()
    local copilot_chat = require("CopilotChat")
    copilot_chat.setup({
      selection = function(source)
        local select = require("CopilotChat.select")
        return source and select.visual(source) or nil
      end,
      mappings = {
        reset = {
          normal = "",
          insert = "",
        },
      },
      -- window = {
      --   layout = "float",
      --   width = 0.8,
      --   height = 0.8,
      --   zindex = 20,
      --   title = ' Copilot Chat ',
      -- },
    })

    -- bugfix for right side window
    vim.api.nvim_create_autocmd("BufWinEnter", {
      pattern = "copilot-chat",
      callback = function()
        vim.cmd("wincmd L")
      end,
    })

    -- auto save & load with picker
    local chat_root = copilot_chat.config.history_path
    local Path = require("plenary.path")

    vim.api.nvim_create_user_command("CopilotChatAutoSave", function()
      local cwd = vim.fn.getcwd()
      local cwd_basename = vim.fn.fnamemodify(cwd, ":t")
      local chat_file = os.date("%Y%m%d") .. "_" .. cwd_basename .. "_" .. vim.fn.sha256(cwd):sub(1, 8)

      vim.cmd("CopilotChatSave " .. chat_file)
    end, {})

    vim.api.nvim_create_user_command("CopilotChatAutoLoad", function()
      local t_builtin = require("telescope.builtin")
      local t_actions = require("telescope.actions")
      local t_action_state = require("telescope.actions.state")

      local function start_picker()
        t_builtin.find_files({
          prompt_title = "Saved Copilot Chats | <C-d>: Delete",
          cwd = Path:new(chat_root):absolute(),
          attach_mappings = function(_, map)
            map({ "i", "n" }, "<CR>", function(prompt_bufnr)
              local selection = t_action_state.get_selected_entry()
              local file = selection.path or selection.filename
              local filename = vim.fn.fnamemodify(file, ":t:r")
              t_actions.close(prompt_bufnr)
              vim.cmd("CopilotChatLoad " .. filename)
            end)
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

    -- Override the default keymaps to use our auto versions
    vim.keymap.set(
      "n",
      "<leader>cS",
      ":CopilotChatAutoSave<CR>",
      { desc = "CopilotChat: Save chat history (auto-named)" }
    )
    vim.keymap.set(
      "n",
      "<leader>cL",
      ":CopilotChatAutoLoad<CR>",
      { desc = "CopilotChat: Load chat history (with selector)" }
    )
  end,
}
