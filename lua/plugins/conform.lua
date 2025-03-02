return {
  'stevearc/conform.nvim',
  config = function()
    local conform = require("conform")
    conform.setup({
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        python = { "black", "ruff" },
      },
      linters_by_ft = {
        python = { "ruff" }
      }
    })
    end,
}
