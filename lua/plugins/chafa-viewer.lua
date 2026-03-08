return {
  name = "chafa-preview.nvim",
  dir = vim.fn.expand("~/code/oneqit/chafa-preview.nvim"),
  lazy = false,
  config = function()
    require("chafa_preview").setup()
  end,
}
