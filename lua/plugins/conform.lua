return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        local conform = require("conform")
        local formatters = conform.list_formatters_to_run()
        local formatter_names = vim.tbl_map(function(f) return f.name end, formatters)
        local filetype = vim.bo.filetype ~= "" and vim.bo.filetype or "plaintext"

        if #formatter_names <= 0 then
          vim.notify("No formatters found for " .. filetype, "warn")
          return
        end

        if #formatter_names == 1 then
          vim.notify("Formatting with " .. formatter_names[1], "info")
          conform.format({ async = true, formatter = formatter_names })
          return
        end

        vim.ui.select(formatter_names, {
          prompt = "Select a formatter:",
        }, function(choice)
          if choice then
            vim.notify("Formatting with " .. choice, "info")
            conform.format({ async = true, formatter = { choice } })
          end
        end)
      end,
      mode = "n",
      desc = "Conform: [c]ode [f]ormat with configured",
    },
    {
      "<leader>cF",
      function()
        require("conform").format({ async = true })
      end,
      mode = "n",
      desc = "Conform: [c]ode [F]ormat with available",
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
      stylua = {
        prepend_args = {
          "--indent-type", "Spaces",
          "--indent-width", "2",
          "--column-width", "120",
          "--sort-requires",
        },
      },
      isort = {
        prepend_args = { "--line-length", "100" },
      },
      black = {
        prepend_args = { "--line-length", "100" },
      },
    },
  },
}
