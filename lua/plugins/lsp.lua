return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      local servers = {
        jsonls = {},
      }

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers or {}),
        handlers = {
          function(server_name)
            local setting = servers[server_name] or {}
            setting.capabilities = vim.tbl_deep_extend("force", {}, capabilities, setting.capabilities or {})
            require("lspconfig")[server_name].setup(setting)
          end,
        },
      })
    end,
  },
}
