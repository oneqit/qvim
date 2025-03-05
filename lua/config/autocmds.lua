vim.api.nvim_create_augroup("FileTypeTabStop", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = "FileTypeTabStop",
  pattern = "python",
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.expandtab = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = "FileTypeTabStop",
  pattern = { "lua", "javascript", "typescript" },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.expandtab = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = "FileTypeTabStop",
  pattern = "go",
  callback = function()
    vim.bo.tabstop = 8
    vim.bo.shiftwidth = 8
    vim.bo.noexpandtab = true
  end,
})
