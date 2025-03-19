return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
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
    },
    keys = {
      -- { "<leader>cc", ":CopilotChat<CR>", desc = "CopilotChat: Open chat with optional input" },
      -- { "<leader>co", ":CopilotChatOpen<CR>", desc = "CopilotChat: Open chat window" },
      { "<leader>cx", ":CopilotChatClose<CR>", desc = "CopilotChat: Close chat window" },
      { "<leader>cc", ":CopilotChatToggle<CR>", desc = "CopilotChat: Toggle chat window" },
      { "<C-a>", ":CopilotChatToggle<CR>", mode = { "n", "i", "v" }, desc = "CopilotChat: Toggle chat window" },
      { "<C-c>", ":CopilotChatStop<CR>", desc = "CopilotChat: Stop current output" },
      { "<leader>cR", ":CopilotChatReset<CR>", desc = "CopilotChat: Reset chat window" },
      { "<leader>cS", ":CopilotChatSave<CR>", desc = "CopilotChat: Save chat history" },
      { "<leader>cL", ":CopilotChatLoad<CR>", desc = "CopilotChat: Load chat history" },
      { "<leader>cP", ":CopilotChatPrompts<CR>", desc = "CopilotChat: View/select prompt templates" },
      { "<leader>cM", ":CopilotChatModels<CR>", desc = "CopilotChat: View/select available models" },
      { "<leader>cA", ":CopilotChatAgents<CR>", desc = "CopilotChat: View/select available agents" },
    },
  },
}
