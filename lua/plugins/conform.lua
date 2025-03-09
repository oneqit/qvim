return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true })
      end,
      mode = "",
      desc = "Conform: [c]ode: [f]ormat",
    },
  },
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
    },
    linters_by_ft = {},
    default_format_opts = {
      lsp_format = "fallback",
    },
    -- format_on_save = { timeout_ms = 500 },
    formatters = {
      isort = {
        prepend_args = { "--line-length", "100" },
      },
      black = {
        prepend_args = { "--line-length", "100" },
      },
    },
  },
}
