return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-ui-select.nvim",
  },
  event = "VeryLazy",
  cmd = "Telescope",
  keys = {
    -- Top
{ "<leader>,", "<cmd>Telescope buffers<cr>", desc = "Telescope: Buffers" },
    { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Telescope: Grep" },
    { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Telescope: Command History" },
    -- find
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Telescope: Buffers" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Telescope: Find Files" },
    { "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Telescope: Find Git Files" },
    -- git
    { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Telescope: Git Branches" },
    { "<leader>gl", "<cmd>Telescope git_commits<cr>", desc = "Telescope: Git Log" },
    { "<leader>gL", "<cmd>Telescope git_bcommits<cr>", desc = "Telescope: Git Log Line" },
    { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Telescope: Git Status" },
    -- Grep
    { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Telescope: Buffer Lines" },
    { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Telescope: Grep" },
    { "<leader>sw", "<cmd>Telescope grep_string<cr>", desc = "Telescope: Word under cursor", mode = { "n", "x" } },
    -- search
    { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Telescope: Registers" },
    { '<leader>s/', "<cmd>Telescope search_history<cr>", desc = "Telescope: Search History" },
    { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Telescope: Autocmds" },
    { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Telescope: Command History" },
    { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Telescope: Commands" },
    { "<leader>sj", "<cmd>Telescope jumplist<cr>", desc = "Telescope: Jumps" },
    { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Telescope: Keymaps" },
    { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Telescope: Resume" },
    { "<leader>uC", "<cmd>Telescope colorscheme<cr>", desc = "Telescope: Colorschemes" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        layout_strategy = "vertical",
        sorting_strategy = "ascending",
        layout_config = {
          width = 0.8,
          height = 0.8,
          preview_cutoff = 20,
          mirror = true,
          prompt_position = "top",
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          no_ignore = true,
        },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
      },
    })
    telescope.load_extension("fzf")
    telescope.load_extension("ui-select")
  end,
}
