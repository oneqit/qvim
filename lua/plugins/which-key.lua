return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      {
        mode = { "n", "v" },
        { "g", group = "Go to" },
        { "<leader>c", group = "Code" },
        { "<leader>cc", group = "CodeCompanion" },
        { "<leader>f", group = "Find/File" },
        { "<leader>g", group = "Git" },
        { "<leader>q", group = "Quit" },
        { "<leader>s", group = "Search" },
        { "<leader>u", group = "UI", icon = { icon = "󰙵 ", color = "cyan" } },
        {
          "<leader>b",
          group = "Buffer",
          expand = function()
            return require("which-key.extras").expand.buf()
          end,
        },
      },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ expand = true })
      end,
      desc = "Keymaps (which-key)",
    },
  },
}
