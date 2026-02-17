local langs = {
  "bash",
  "java",
  "json",
  "kotlin",
  "lua",
  "markdown",
  "markdown_inline",
  "perl",
  "python",
  "vimdoc",
  "yaml",
}

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    require("nvim-treesitter").install(langs)
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
