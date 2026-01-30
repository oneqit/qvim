local themes = {
  "catppuccin-mocha",
  "catppuccin-macchiato",
  "catppuccin-frappe",
  "catppuccin-latte",
  "tokyonight-night",
  "tokyonight-storm",
  "tokyonight-moon",
  "tokyonight-day",
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
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme catppuccin-mocha]])
    end,
    keys = {
      { "<leader>tt", rotate_theme, desc = "Rotate theme" },
    },
  },
}
