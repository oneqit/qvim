return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      ensure_installed = { "lua", "vimdoc", "python", "markdown" },
      -- indent = { enable = true },
    })
  end,
}
