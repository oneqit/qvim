-- Disable italic
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local hls = vim.api.nvim_get_hl(0, {})
    for name, hl in pairs(hls) do
      if hl.italic then
        hl.italic = false
        vim.api.nvim_set_hl(0, name, hl)
      end
    end
  end,
})

-- Indent
vim.api.nvim_create_augroup("FileTypeTabStop", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = "FileTypeTabStop",
  pattern = "python",
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.expandtab = true
    vim.opt.colorcolumn = "100"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = "FileTypeTabStop",
  pattern = { "lua", "javascript", "typescript", "json" },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.expandtab = true
    vim.opt.colorcolumn = "120"
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
