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
      vim.cmd([[colorscheme monokai-pro-ristretto]])
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
