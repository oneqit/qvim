-- reference: https://github.com/hendrikmi/dotfiles/blob/main/nvim/lua/plugins/lsp.lua
-- reference: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "nvim-telescope/telescope.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      {
        "j-hui/fidget.nvim",
        tag = "v1.4.0",
        opts = {
          progress = {
            display = {
              done_icon = "✓", -- Icon shown when all LSP progress tasks are complete
            },
          },
          notification = {
            window = {
              winblend = 0, -- Background color opacity in the notification window
            },
          },
        },
      },
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        -- Create a function that lets us more easily define mappings specific LSP related items.
        -- It sets the mode, buffer and description for us each time.
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  To jump back, press <C-T>.
          map("gd", require("telescope.builtin").lsp_definitions, "[g]oto [d]efinition")

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header
          map("gD", vim.lsp.buf.declaration, "[g]oto [d]eclaration")

          -- Find references for the word under your cursor.
          map("gr", require("telescope.builtin").lsp_references, "[g]oto [r]eferences")

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map("gI", require("telescope.builtin").lsp_implementations, "[g]oto [I]mplementation")

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map("gy", require("telescope.builtin").lsp_type_definitions, "[g]oto t[y]pe definition")

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map("<leader>ss", require("telescope.builtin").lsp_document_symbols, "[s]earch [s]ymbols")

          -- Fuzzy find all the symbols in your current workspace
          --  Similar to document symbols, except searches over your whole project.
          map("<leader>sS", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[s]earch workspace [S]ymbols")

          -- Rename the variable under your cursor
          --  Most Language Servers support renaming across files, etc.
          map("<leader>cr", vim.lsp.buf.rename, "[c]ode [r]ename")

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ction")

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap
          vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
            border = "rounded",
          })
          map("K", function()
            -- call twice for focusing the floating window
            vim.lsp.buf.hover()
            vim.lsp.buf.hover()
          end, "Hover Documentation")

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      local pipenv_python = vim.fn.system("pipenv --py 2>/dev/null"):gsub("\n", "")
      local pyenv_python = vim.fn.system("pyenv which python 2>/dev/null"):gsub("\n", "")
      local global_python = vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3")
        or (vim.fn.exepath("python") ~= "" and vim.fn.exepath("python"))
        or ""
      local python_path = pipenv_python ~= "" and pipenv_python
        or (pyenv_python ~= "" and pyenv_python)
        or global_python

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- Enable the following language servers
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { disable = { "undefined-global", "missing-fields" } },
            },
          },
        },
        -- pylsp = {
        --   settings = {
        --     pylsp = {
        --       plugins = {
        --         pyflakes = { enabled = false },
        --         pycodestyle = { enabled = false, maxLineLength = 100 },
        --         autopep8 = { enabled = false },
        --         yapf = { enabled = false },
        --         mccabe = { enabled = false },
        --         pylsp_mypy = { enabled = false },
        --         pylsp_black = { enabled = false },
        --         pylsp_isort = { enabled = false },
        --       },
        --     },
        --   },
        -- },
        pyright = {
          -- Config options: https://github.com/microsoft/pyright/blob/main/docs/settings.md
          settings = {
            pyright = {
              disableOrganizeImports = true, -- Using Ruff's import organizer
            },
            python = {
              pythonPath = python_path,
              analysis = {
                ignore = { '*' },              -- Ignore all files for analysis to exclusively use Ruff for linting
                typeCheckingMode = "basic",
                autoImportCompletions = true, -- whether pyright offers auto-import completions
              },
            },
          },
        },
        ruff = {
          init_options = {
            settings = {
              lineLength = 100,
            },
          },
        },
        jsonls = {},
        sqlls = {},
      }

      require("mason").setup()
      require("mason-tool-installer").setup({ ensure_installed = { "stylua" } })
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers or {}),
        handlers = {
          function(server_name)
            local setting = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            setting.capabilities = vim.tbl_deep_extend("force", {}, capabilities, setting.capabilities or {})
            require("lspconfig")[server_name].setup(setting)
          end,
        },
      })
    end,
  },
}
