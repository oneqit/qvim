if true then return {} end
return {
  {
    "neoclide/coc.nvim",
    branch = "release",
    config = function()
      vim.g.coc_global_extensions = {
        "coc-json",
        "coc-lua",
        "coc-pyright",
      }
      vim.g.coc_list_window = {
        border = "single",
        height = 15,
        col = 0,
        row = 1, -- Adjust this to position it above
      }
    end,
  },
}
