local map = vim.keymap.set

return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    config = function()
      require("mason").setup()
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = { "stylua" },
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright" },
        automatic_installation = true,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({})
      -- lspconfig.pylsp.setup({
      --   settings = {
      --     pylsp = {
      --       plugins = {
      --         pycodestyle = {
      --           maxLineLength = 88
      --         }
      --       }
      --     }
      --   }
      -- })

      local pipenv_python = vim.fn.system("pipenv --py 2>/dev/null"):gsub("\n", "")
      local pyenv_python = vim.fn.system("pyenv which python 2>/dev/null"):gsub("\n", "")
      local global_python = vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3")
        or (vim.fn.exepath("python") ~= "" and vim.fn.exepath("python"))
        or ""
      local python_path = pipenv_python ~= "" and pipenv_python
        or (pyenv_python ~= "" and pyenv_python)
        or global_python

      lspconfig.pyright.setup({
        settings = {
          python = {
            pythonPath = python_path,
            analysis = {
              typeCheckingMode = "basic",
            },
          },
        },
      })

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
      })
      map("n", "K", function()
        -- call twice for focusing the floating window
        vim.lsp.buf.hover()
        vim.lsp.buf.hover()
      end, { desc = "Hover" })
      map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
    end,
  },
}
