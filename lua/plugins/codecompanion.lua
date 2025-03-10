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
          adapter = "ollama",
        },
        inline = {
          adapter = "ollama",
        },
      },
      display = {
        chat = {
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
      { "n", "v" },
      "<C-a>",
      "<cmd>CodeCompanionChat Toggle<cr>",
      { noremap = true, silent = true, desc = "CodeCompanion: Toggle code companion chat" }
    )
    vim.keymap.set(
      { "n", "v" },
      "<leader>cca",
      "<cmd>CodeCompanionActions<cr>",
      { noremap = true, silent = true, desc = "CodeCompanion: [c]ode [c]ompanion [a]ctions" }
    )
    vim.keymap.set(
      { "n", "v" },
      "<leader>cct",
      "<cmd>CodeCompanionChat Toggle<cr>",
      { noremap = true, silent = true, desc = "CodeCompanion: [c]ode [c]ompanion [t]oggle" }
    )
    vim.keymap.set(
      "v",
      "<leader>ccy",
      "<cmd>CodeCompanionChat Add<cr>",
      { noremap = true, silent = true, desc = "CodeCompanion: [c]ode [c]ompanion cop[y] to chat" }
    )
  end,
}
