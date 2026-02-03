local themes = {
  "monokai-pro-ristretto",
  "monokai-pro-classic",
  "github_dark_dimmed",
  "catppuccin-mocha",
  "tokyonight-night",
  "cyberdream",
}

local current_index = 1

local function rotate_theme()
  current_index = current_index % #themes + 1
  local theme = themes[current_index]
  vim.cmd("colorscheme " .. theme)
  vim.notify("Theme: " .. theme, vim.log.levels.INFO)
end

return {
  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local function apply_neo_tree_hl()
        vim.api.nvim_set_hl(0, "NeoTreeNormal", { fg = "#fff1f3", bg = "#211c1c" })
        vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { fg = "#fff1f3", bg = "#211c1c" })
        vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", { fg = "#fff1f3" })
        vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { fg = "#fd9353" })
        vim.api.nvim_set_hl(0, "NeoTreeDotfile", { fg = "#948a8b" })
        vim.api.nvim_set_hl(0, "NeoTreeHiddenByName", { fg = "#948a8b" })
      end

      vim.cmd([[colorscheme monokai-pro-ristretto]])

      -- Apply neo-tree highlights for monokai-pro
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "monokai-pro*",
        callback = apply_neo_tree_hl,
      })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "neo-tree",
        callback = function()
          if (vim.g.colors_name or ""):match("^monokai%-pro") then
            apply_neo_tree_hl()
          end
        end,
      })
    end,
    keys = {
      { "<leader>tr", rotate_theme, desc = "Rotate theme" },
    },
  },
  {
    "projekt0n/github-nvim-theme",
    lazy = false,
    priority = 1000,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    keys = {
      { "<leader>tR", "<cmd>CyberdreamToggleMode<cr>", desc = "Toggle Cyberdream mode" },
    },
  },
}
