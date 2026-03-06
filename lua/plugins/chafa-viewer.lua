return {
  name = "chafa-viewer",
  dir = vim.fn.stdpath("config"),
  lazy = false,
  priority = 1,
  config = function()
    require("chafa_viewer").setup()
  end,
}
