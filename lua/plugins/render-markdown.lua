return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown" },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    enabled = false,
    anti_conceal = { enabled = false },
  },
  keys = {
    { "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Render Markdown", ft = "markdown" },
  },
}
