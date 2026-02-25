return {
  "mistweaverco/kulala.nvim",
  ft = { "http", "rest" },
  keys = {
    { "<leader>Rs", desc = "Kulala: Send request" },
    { "<leader>Ra", desc = "Kulala: Send all requests" },
    { "<leader>Rb", desc = "Kulala: Open scratchpad" },
  },
  opts = {
    global_keymaps = true,
    global_keymaps_prefix = "<leader>R",
    kulala_keymaps_prefix = "",
  },
}
