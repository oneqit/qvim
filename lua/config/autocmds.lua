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

-- Delete initial empty buffer when opening the first file (only if no other buffers exist)
do
  local initial_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("CleanInitialBuffer", { clear = true }),
    once = true,
    callback = function(args)
      if args.buf == initial_buf then return end
      local listed = vim.tbl_filter(function(b)
        return vim.bo[b].buflisted
      end, vim.api.nvim_list_bufs())
      if #listed ~= 2 then return end
      if vim.api.nvim_buf_is_valid(initial_buf)
        and vim.api.nvim_buf_get_name(initial_buf) == ""
        and vim.api.nvim_buf_line_count(initial_buf) <= 1
        and vim.api.nvim_buf_get_lines(initial_buf, 0, 1, false)[1] == ""
      then
        vim.api.nvim_buf_delete(initial_buf, {})
      end
    end,
  })
end

-- Auto reload files when changed externally
vim.opt.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("AutoReload", { clear = true }),
  pattern = "*",
  command = "checktime",
})
