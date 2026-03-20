return {
  "hat0uma/csvview.nvim",
  ft = { "csv", "tsv" },
  opts = {
    view = {
      display_mode = "border",
    },
  },
  keys = {
    { "<leader>uc", "<cmd>CsvViewToggle<cr>", desc = "Toggle CSV View", ft = { "csv", "tsv" } },
  },
}
